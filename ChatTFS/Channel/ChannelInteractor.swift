import Foundation
import Combine
import TFSChatTransport

protocol ChannelInteractorProtocol: AnyObject {
    func loadData()
    func createMessageData(messageText: String)
    var dataHandler: (([Message], Channel) -> Void)? { get set }
}

class ChannelInteractor: ChannelInteractorProtocol {
    
    init(chatService: ChatService, channelID: String, dataManager: DataManagerProtocol, coreDataService: CoreDataServiceProtocol) {
        self.chatService = chatService
        self.channelID = channelID
        self.dataManager = dataManager
        self.coreDataService = coreDataService
    }
    
    // MARK: - Public properties
    
    weak var chatService: ChatService?
    weak var presenter: ChannelPresenterProtocol?
    weak var dataManager: DataManagerProtocol?
    weak var coreDataService: CoreDataServiceProtocol?
    var dataHandler: (([Message], Channel) -> Void)?
    
    // MARK: - Private properties
    
    private var userID: String?
    private var userName: String?
    private var channelID: String?
    private var dataMessagesRequest: Cancellable?
    private var dataChannelRequest: Cancellable?
    private var sendMessageRequest: Cancellable?
    private var userDataRequest: Cancellable?
    
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
            .sink(receiveCompletion: { [weak self] _ in
                self?.dataMessagesRequest?.cancel()
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
            .sink(receiveCompletion: { [weak self] _ in
                self?.sendMessageRequest?.cancel()
            }, receiveValue: { [weak self] message in
                self?.presenter?.uploadMessage(messageModel: message)
            })
    }
}
