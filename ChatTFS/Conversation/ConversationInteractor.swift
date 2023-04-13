import Foundation
import Combine
import TFSChatTransport

protocol ConversationInteractorProtocol: AnyObject {
    func loadData()
    func createMessageData(messageText: String)
    var dataHandler: (([Message], Channel) -> Void)? { get set }
}

class ConversationInteractor: ConversationInteractorProtocol {
    
    init(chatService: ChatService, channelID: String, dataManager: DataManagerProtocol) {
        self.chatService = chatService
        self.channelID = channelID
        self.dataManager = dataManager
    }
    
    // MARK: - Public
    
    weak var chatService: ChatService?
    weak var presenter: ConversationPresenterProtocol?
    weak var dataManager: DataManagerProtocol?
    var channelID: String?
    var dataMessagesRequest: Cancellable?
    var dataChannelRequest: Cancellable?
    var sendMessageRequest: Cancellable?
    var userDataRequest: Cancellable?
    var dataHandler: (([Message], Channel) -> Void)?
    var userID: String?
    var userName: String?
    
    // MARK: - Methods
    
    func loadData() {
        
        dataHandler = { [weak self] messagesData, channelData in
            self?.presenter?.channelData = channelData
            self?.presenter?.messagesData = messagesData
            self?.dataChannelRequest?.cancel()
            self?.dataMessagesRequest?.cancel()
        }
        
        dataChannelRequest = chatService?.loadChannel(id: channelID ?? "")
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { [weak self] channel in
                self?.loadMessagesData(channelID: channel.id, channelData: channel)
            })
        
        userDataRequest = dataManager?.readProfilePublisher()
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .decode(type: ProfileModel.self, decoder: JSONDecoder())
            .catch({_ in
                Just(ProfileModel(fullName: nil, statusText: nil, profileImageData: nil))})
            .sink(receiveValue: { [weak self] profile in
                self?.userID = self?.dataManager?.userId
                self?.userName = profile.fullName
            })
    }
    
    func loadMessagesData(channelID: String, channelData: Channel) {
        dataMessagesRequest = self.chatService?.loadMessages(channelId: channelID)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { [weak self] messagesData in
                self?.dataHandler?(messagesData, channelData)
                self?.presenter?.dataUploaded(userID: self?.userID ?? "")
            })
    }
    
    func createMessageData(messageText: String) {
        guard let channelID = channelID else { return }
        sendMessageRequest = chatService?.sendMessage(text: messageText,
                                                      channelId: channelID,
                                                      userId: userID ?? "",
                                                      userName: userName ?? "")
            .sink(receiveCompletion: { _ in
            }, receiveValue: { [weak self] message in
                self?.presenter?.uploadMessage(messageModel: message)
            })
    }
}
