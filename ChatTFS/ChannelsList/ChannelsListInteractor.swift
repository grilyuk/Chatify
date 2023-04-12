import UIKit
import CoreData
import Combine
import TFSChatTransport

protocol ChannelsListInteractorProtocol: AnyObject {
    func loadData()
    func createChannel(channelName: String)
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
    private var sentChannels: [ChannelNetworkModel] = []
    
    // MARK: - Public methods
    
    func loadData() {
        
        handler = { [weak self] channels in
            self?.presenter?.dataChannels = channels
            self?.presenter?.dataUploaded()
            self?.sentChannels = []
            self?.channelsRequest?.cancel()
        }
        
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
                self?.saveChannelsList(with: convertedChannel)
            })
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
            
            sentChannels.append(contentsOf: channelsModel)
            self.handler?(self.sentChannels)
        } catch {
            print(error)
        }
    }
    
    private func loadFromNetwork() {
        
        channelsRequest = chatService.loadChannels()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] _ in
                self?.loadFromCoreData()
                self?.presenter?.interactorError()
            }, receiveValue: { [weak self] channels in
                
                guard
                    let self
                else {
                    return
                }
                
                channels.forEach { channel in
                    if !self.sentChannels.contains(where: { $0.id == channel.id }) {
                        let convertedChannel = ChannelNetworkModel(id: channel.id,
                                                                   name: channel.name,
                                                                   logoURL: channel.logoURL,
                                                                   lastMessage: channel.lastMessage,
                                                                   lastActivity: channel.lastActivity)
                        self.saveChannelsList(with: convertedChannel)
                        self.sentChannels.append(convertedChannel)
                    }
                }
                self.handler?(self.sentChannels)
            })
    }
    
    private func saveChannelsList(with channel: ChannelNetworkModel) {
        
        coreDataService.save { context in
            let channelManagedObject = DBChannel(context: context)
            channelManagedObject.id = channel.id
            channelManagedObject.name = channel.name
            channelManagedObject.lastActivity = channel.lastActivity
            channelManagedObject.lastMessage = channel.lastMessage
            channelManagedObject.messages = NSOrderedSet()
            print("Save channel")
        }
    }
}
