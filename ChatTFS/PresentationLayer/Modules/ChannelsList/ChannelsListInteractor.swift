import UIKit
import CoreData
import Combine
import TFSChatTransport

protocol ChannelsListInteractorProtocol: AnyObject {
    func loadData()
    func createChannel(channelName: String)
    func deleteChannel(id: String) -> Bool
}

class ChannelsListInteractor: ChannelsListInteractorProtocol {
    
    // MARK: - Initialization
    
    init(chatService: ChatService, coreDataService: CoreDataServiceProtocol) {
        self.chatService = chatService
        self.coreDataService = coreDataService
    }
    
    // MARK: - Public
    
    weak var presenter: ChannelsListPresenterProtocol?
    var chatService: ChatService
    var coreDataService: CoreDataServiceProtocol
    
    // MARK: - Private
    
    private var handler: (([ChannelNetworkModel]) -> Void)?
    private var channelsRequest: Cancellable?
    private var deleteChannelRequest: Cancellable?
    private var cacheChannels: [ChannelNetworkModel] = []
    private var networkChannels: [ChannelNetworkModel] = []
    
    // MARK: - Public methods
    
    func loadData() {
        
        handler = { [weak self] channels in
            self?.presenter?.dataChannels = channels
            self?.presenter?.dataUploaded()
            self?.networkChannels = []
            self?.channelsRequest?.cancel()
        }
        
        loadFromCoreData()
        loadFromNetwork()
    }
    
    func createChannel(channelName: String) {
        channelsRequest = chatService.createChannel(name: channelName,
                                                    logoUrl: "https://source.unsplash.com/random/600x600")
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { [weak self] channel in
                let convertedChannel = ChannelNetworkModel(from: channel)
                self?.presenter?.addChannel(channel: convertedChannel)
                self?.coreDataService.saveChannelsList(with: [convertedChannel])
            })
    }
    
    func deleteChannel(id: String) -> Bool {
        deleteChannelRequest = chatService.deleteChannel(id: id)
            .receive(on: DispatchQueue.main)
            .subscribe(on: DispatchQueue.global())
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.presenter?.interactorError()
                    print(error.localizedDescription)
                case .finished:
                    self?.coreDataService.deleteChannel(channelID: id)
                }
            }, receiveValue: { _ in
            })
        return true
    }
    
    // MARK: - Private methods
    
    private func loadFromCoreData() {
        cacheChannels.append(contentsOf: coreDataService.getChannelsFromDB())
        self.handler?(cacheChannels)
    }
    
    private func loadFromNetwork() {
        
        channelsRequest = chatService.loadChannels()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] _ in
                self?.presenter?.interactorError()
            }, receiveValue: { [weak self] channels in

                guard let self else { return }
                
                channels.forEach { networkChannel in
                    
                    if !self.cacheChannels.contains(where: { networkChannel.id == $0.id }) {
                        self.coreDataService.saveChannelsList(with: [ChannelNetworkModel(id: networkChannel.id,
                                                                         name: networkChannel.name,
                                                                         logoURL: networkChannel.logoURL,
                                                                         lastMessage: networkChannel.lastMessage,
                                                                         lastActivity: networkChannel.lastActivity)])
                    }
                    
                    self.networkChannels.append(ChannelNetworkModel(id: networkChannel.id,
                                                           name: networkChannel.name,
                                                           logoURL: networkChannel.logoURL,
                                                           lastMessage: networkChannel.lastMessage,
                                                           lastActivity: networkChannel.lastActivity))
                }
                
                let cachedIDs = self.cacheChannels.map { $0.id }
                let networkIDs = self.networkChannels.map { $0.id }
                
                let deletedChannels = cachedIDs.filter { !networkIDs.contains($0) }
                
                for deletedChannel in deletedChannels {
                    self.coreDataService.deleteChannel(channelID: deletedChannel)
                }
                
                self.networkChannels.sort(by: { $0.lastActivity ?? Date() < $1.lastActivity ?? Date() })
                self.cacheChannels.sort(by: { $0.lastActivity ?? Date() < $1.lastActivity ?? Date() })
                
                for (networkElement, cacheElement) in zip(self.networkChannels, self.cacheChannels) {
                    if networkElement.lastActivity != cacheElement.lastActivity || networkElement.lastMessage != cacheElement.lastMessage {
                        coreDataService.updateChannel(for: networkElement)
                        }
                }
                
                self.cacheChannels = []
                
                self.handler?(self.networkChannels)
            })
    }
}
