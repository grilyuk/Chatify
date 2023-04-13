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
                let convertedChannel = ChannelNetworkModel(id: channel.id,
                                                           name: channel.name,
                                                           logoURL: channel.logoURL,
                                                           lastMessage: channel.lastMessage,
                                                           lastActivity: channel.lastActivity)
                self?.presenter?.addChannel(channel: convertedChannel)
                self?.saveChannelsList(with: [convertedChannel])
            })
    }
    
    func deleteChannel(id: String) -> Bool {
        var result = true
        deleteChannelRequest = chatService.deleteChannel(id: id)
            .receive(on: DispatchQueue.main)
            .subscribe(on: DispatchQueue.global())
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.presenter?.interactorError()
                    print(error.localizedDescription)
                case .finished:
                    self?.coreDataService.deleteObject(loggerText: "channel \(id) delete", channelID: id)
                }
            }, receiveValue: { _ in
            })
        return result
    }
    
    // MARK: - Private methods
    
    private func loadFromCoreData() {
        do {
            let dbChannels = try coreDataService.fetchChannelsList()
            let channelsModel: [ChannelNetworkModel] = dbChannels
                .compactMap { channelsDB in
                    guard
                        let id = channelsDB.id,
                        let name = channelsDB.name
                    else {
                        return ChannelNetworkModel(id: "", name: "", logoURL: "", lastMessage: "", lastActivity: Date())
                    }
                    return ChannelNetworkModel(id: id,
                                               name: name,
                                               logoURL: nil,
                                               lastMessage: channelsDB.lastMessage,
                                               lastActivity: channelsDB.lastActivity)
                }
            
            cacheChannels.append(contentsOf: channelsModel)
            self.handler?(channelsModel)
        } catch {
            print(error)
        }
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
                        self.saveChannelsList(with: [ChannelNetworkModel(id: networkChannel.id,
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
                    self.coreDataService.deleteObject(loggerText: "Delete channel \(deletedChannel)",
                                                      channelID: deletedChannel)
                }
                
                self.cacheChannels = []
                
                self.saveChannelsList(with: self.networkChannels)
                self.handler?(self.networkChannels)
            })
    }
    
    private func saveChannelsList(with channels: [ChannelNetworkModel]) {
        for channel in channels {
            let loggerText = "Save channel \(channel.name)"
            coreDataService.save(loggerText: loggerText) { context in
                let channelManagedObject = DBChannel(context: context)
                channelManagedObject.id = channel.id
                channelManagedObject.name = channel.name
                channelManagedObject.lastActivity = channel.lastActivity
                channelManagedObject.lastMessage = channel.lastMessage
                channelManagedObject.messages = NSOrderedSet()
            }
        }
    }
    
    private func updateChannel(for channels: ChannelNetworkModel) {
        
    }
}
