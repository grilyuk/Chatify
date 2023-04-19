import Foundation
import Combine
import TFSChatTransport

protocol ChannelInteractorProtocol: AnyObject {
    func loadData()
    func createMessage(messageText: String, userID: String, userName: String)
    var handler: (([MessageNetworkModel], ChannelNetworkModel) -> Void)? { get set }
}

class ChannelInteractor: ChannelInteractorProtocol {
    
    init(chatService: ChatServiceProtocol, channelID: String, coreDataService: CoreDataServiceProtocol) {
        self.chatService = chatService
        self.channelID = channelID
        self.coreDataService = coreDataService
        self.DBChannel = coreDataService.getDBChannel(channel: channelID)
    }
    
    // MARK: - Public properties
    
    weak var presenter: ChannelPresenterProtocol?
    var handler: (([MessageNetworkModel], ChannelNetworkModel) -> Void)?
    
    // MARK: - Private properties
    
    private let chatService: ChatServiceProtocol
    private let coreDataService: CoreDataServiceProtocol
    private let DBChannel: ChannelNetworkModel
    private var channelID: String
    private var cacheMessages: [MessageNetworkModel] = []
    private var networkMessages: [MessageNetworkModel] = []
    
    // MARK: - Public methods
    
    func loadData() {
        
        handler = { [weak self] messagesData, channelData in
            self?.presenter?.channelData = channelData
            self?.presenter?.messagesData = messagesData
            self?.presenter?.dataUploaded()
        }
        
        loadFromCoreData(channel: channelID)
        loadFromNetwork(channel: channelID)
    }
    
    func createMessage(messageText: String, userID: String, userName: String) {
        let newMessage = chatService.createMessageData(messageText: messageText,
                                      channelID: channelID,
                                      userID: userID,
                                      userName: userName)
        newMessage
        .sink(receiveCompletion: { _ in
        }, receiveValue: { [weak self] message in
            guard let self else { return }
            self.coreDataService.saveMessagesForChannel(for: self.channelID,
                                                        messages: [message])
            
            self.presenter?.uploadMessage(messageModel: message)
        })
        .cancel()
    }
    
    // MARK: - Private methods
    
    private func loadFromCoreData(channel: String) {
        let DBMessages = coreDataService.getMessagesFromDBChannel(channel: channel)
        cacheMessages.append(contentsOf: DBMessages)
        handler?(cacheMessages, DBChannel)
    }
    
    private func loadFromNetwork(channel: String) {
        chatService.loadMessagesFrom(channelID: channel)
            .sink { [weak self] result in
                guard let self else { return }
                switch result {
                case .finished:
                    self.coreDataService.saveMessagesForChannel(for: self.channelID,
                                                                messages: self.networkMessages)
                    self.handler?(self.networkMessages, self.DBChannel)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            } receiveValue: { [weak self] messages in
                guard let self else { return }
                self.compareMessages(cacheMessages: self.cacheMessages, networkMessages: messages)
            }
            .cancel()
    }
    
    private func compareMessages(cacheMessages: [MessageNetworkModel], networkMessages: [MessageNetworkModel]) {
        
        let cacheMessagesIDs = cacheMessages.map { $0.id }
        let networkMessagesIDs = networkMessages.map { $0.id }

        let newMessages = networkMessagesIDs.filter { !(cacheMessagesIDs.contains($0)) }

        for newMessage in newMessages {
            self.networkMessages = networkMessages.filter({ $0.id == newMessage })
        }
    }
}
