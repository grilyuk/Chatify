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
            self.sentChannels = []
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
                var newChannels: [ChannelNetworkModel] = []
                channels.forEach { networkChannel in
                    
                    newChannels.append(ChannelNetworkModel(id: networkChannel.id,
                                                           name: networkChannel.name,
                                                           logoURL: networkChannel.logoURL,
                                                           lastMessage: networkChannel.lastMessage,
                                                           lastActivity: networkChannel.lastActivity))
                }
                
                for sentChannel in sentChannels {
                    for newChannel in newChannels where newChannel.id != sentChannel.id {
                        sentChannels.removeAll(where: { newChannel.id != $0.id })
                    }
                }
                self.coreDataService.deleteObject(loggerText: "Deleting object",
                                                  channelID: "a0ff5a19-809c-48a8-a385-b87cdc50fa3d")
                self.saveChannelsList(with: newChannels)
                self.handler?(newChannels)
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
}
