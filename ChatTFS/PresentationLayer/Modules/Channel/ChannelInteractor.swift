import Foundation
import Combine
import TFSChatTransport

protocol ChannelInteractorProtocol: AnyObject {
    
    func loadData()
    func createMessageData(messageText: String, userID: String, userName: String)
    var dataHandler: (([MessageNetworkModel], ChannelNetworkModel) -> Void)? { get set }
}

class ChannelInteractor: ChannelInteractorProtocol {
    
    init(chatService: ChatService, channelID: String, coreDataService: CoreDataServiceProtocol) {
        self.chatService = chatService
        self.channelID = channelID
        self.coreDataService = coreDataService
    }
    
    // MARK: - Public properties
    
    weak var chatService: ChatService?
    weak var presenter: ChannelPresenterProtocol?
    weak var dataManager: FileManagerServiceProtocol?
    var dataHandler: (([MessageNetworkModel], ChannelNetworkModel) -> Void)?
    
    // MARK: - Private properties
    
    private var coreDataService: CoreDataServiceProtocol
    private var channelID: String?
    private var dataMessagesRequest: Cancellable?
    private var dataChannelRequest: Cancellable?
    private var sendMessageRequest: Cancellable?
    private var sentMessages: [MessageNetworkModel] = []
    
    // MARK: - Public methods
    
    func loadData() {
        
        dataHandler = { [weak self] messagesData, channelData in
            self?.presenter?.channelData = channelData
            self?.presenter?.messagesData = messagesData
            self?.presenter?.dataUploaded()
            self?.dataChannelRequest?.cancel()
            self?.dataMessagesRequest?.cancel()
        }
        
        guard let channelID
        else {
            return
        }
        
        loadFromCoreData(channel: channelID)
        loadFromNetwork(channel: channelID)
        
    }
    
    func createMessageData(messageText: String, userID: String, userName: String) {
        guard let channelID = channelID else { return }
        sendMessageRequest = chatService?.sendMessage(text: messageText,
                                                      channelId: channelID,
                                                      userId: userID,
                                                      userName: userName)
        .sink(receiveCompletion: { [weak self] _ in
            self?.sendMessageRequest?.cancel()
        }, receiveValue: { [weak self] message in
            self?.coreDataService.saveMessagesForChannel(for: channelID,
                                         messages: [MessageNetworkModel(from: message)])
            self?.presenter?.uploadMessage(messageModel: message)
        })
    }
    
    // MARK: - Private methods
    
    private func loadFromCoreData(channel: String) {
        let DBChannel = coreDataService.getDBChannel(channel: channel)
        let DBMessages = coreDataService.getMessagesFromDBChannel(channel: channel)
        sentMessages.append(contentsOf: DBMessages)
        dataHandler?(sentMessages, DBChannel)
    }
    
    private func loadFromNetwork(channel: String) {
        
        dataChannelRequest = chatService?.loadChannel(id: channel)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { [weak self] channel in
                self?.loadMessagesData(channelID: channel.id, channelData: channel)
            })
    }
    
    private func loadMessagesData(channelID: String, channelData: Channel) {
        
        dataMessagesRequest = self.chatService?.loadMessages(channelId: channelID)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] _ in
                
                self?.dataMessagesRequest?.cancel()
            }, receiveValue: { [weak self] messagesData in
                
                let networkChannelModel = ChannelNetworkModel(id: channelData.id,
                                                              name: channelData.name,
                                                              logoURL: nil,
                                                              lastMessage: nil,
                                                              lastActivity: nil)
                
                let networkMessages = messagesData
                    .compactMap({ MessageNetworkModel(id: $0.id,
                                                      text: $0.text,
                                                      userID: $0.userID,
                                                      userName: $0.userName,
                                                      date: $0.date)
                    })
                
                let cacheMessagesIDs = self?.sentMessages.map { $0.id }
                let networkMessagesIDs = networkMessages.map { $0.id }
                
                guard let cacheMessagesIDs else {
                    return
                }
                
                let newMessages = networkMessagesIDs.filter { !(cacheMessagesIDs.contains($0)) }
                
                var messagesToSave = networkMessages
                
                for newMessage in newMessages {
                    messagesToSave = networkMessages.filter({ $0.id == newMessage })
                }
                
                self?.coreDataService.saveMessagesForChannel(for: channelID,
                                             messages: messagesToSave)
                self?.dataHandler?(networkMessages, networkChannelModel)
                self?.presenter?.dataUploaded()
            })
    }
}
