import Foundation
import Combine
import TFSChatTransport

protocol ChannelInteractorProtocol: AnyObject {
    var handler: (([MessageNetworkModel], ChannelNetworkModel) -> Void)? { get set }
    func loadData()
    func createMessage(messageText: String, userID: String, userName: String)
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
            self?.networkMessages = []
        }
        
        loadFromCoreData(channel: channelID)
        loadFromNetwork(channel: channelID)
    }
    
    func createMessage(messageText: String, userID: String, userName: String) {
        chatService.createMessageData(messageText: messageText,
                                      channelID: channelID,
                                      userID: userID,
                                      userName: userName)
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
            .sink { result in
                switch result {
                case .finished:
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                }
            } receiveValue: { [weak self] messages in
                guard let self else { return }
                self.compareMessages(cacheMessages: self.cacheMessages, networkMessages: messages)
                self.handler?(messages, self.DBChannel)
            }
            .cancel()
    }
    
    private func compareMessages(cacheMessages: [MessageNetworkModel], networkMessages: [MessageNetworkModel]) {
        
        let cacheMessagesIDs = cacheMessages.map { $0.id }
        let networkMessagesIDs = networkMessages.map { $0.id }

        let newMessages = networkMessagesIDs.filter { !(cacheMessagesIDs.contains($0)) }

        for newMessage in newMessages {
            self.coreDataService.saveMessagesForChannel(for: self.channelID,
                                                        messages: networkMessages.filter({ $0.id == newMessage }))
        }
    }
}
