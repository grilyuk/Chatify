import Foundation
import Combine
import TFSChatTransport

protocol ConversationInteractorProtocol: AnyObject {
    func loadData()
    var dataHandler: (([Message], Channel) -> Void)? { get set }
}

class ConversationInteractor: ConversationInteractorProtocol {
    
    init(chatService: ChatService, channelID: String) {
        self.chatService = chatService
        self.channelID = channelID
    }
    
    // MARK: - Public
    
    weak var chatService: ChatService?
    weak var presenter: ConversationPresenterProtocol?
    var channelID: String?
    var dataMessagesRequest: Cancellable?
    var dataChannelRequest: Cancellable?
    var dataHandler: (([Message], Channel) -> Void)?
    
    // MARK: - Methods
    
    func loadData() {
        
        dataHandler = { [weak self] messagesData, channelData in
            self?.presenter?.channelData = channelData
            self?.presenter?.messagesData = messagesData
            self?.presenter?.dataUploaded()
            self?.dataChannelRequest?.cancel()
            self?.dataMessagesRequest?.cancel()
        }
        
        dataChannelRequest = chatService?.loadChannel(id: channelID ?? "")
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { [weak self] channel in
                self?.loadMessagesData(channelID: channel.id, channelData: channel)
            })
    }
    
    func loadMessagesData(channelID: String, channelData: Channel) {
        dataMessagesRequest = self.chatService?.loadMessages(channelId: channelID)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { [weak self] messagesData in
                self?.dataHandler?(messagesData, channelData)
            })
    }
}
