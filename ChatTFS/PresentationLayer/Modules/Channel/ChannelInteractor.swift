import Foundation
import Combine
import TFSChatTransport

protocol ChannelInteractorProtocol: AnyObject {
    var handler: (([MessageNetworkModel], ChannelNetworkModel) -> Void)? { get set }
    var userName: String { get set }
    var userID: String { get set }
    func loadData()
    func createMessage(messageText: String, userID: String, userName: String)
    func getChannelImage(for channel: ChannelNetworkModel) -> UIImage
    func getImageForMessage(link: String) -> UIImage
    func subscribeToSSE()
    func unsubscribeFromSSE()
}

class ChannelInteractor: ChannelInteractorProtocol {
    
    // MARK: - Initialization
    
    init(chatService: ChatServiceProtocol,
         channelID: String,
         coreDataService: CoreDataServiceProtocol,
         dataManager: FileManagerServiceProtocol,
         imageLoaderService: ImageLoaderServiceProtocol) {
        
        self.chatService = chatService
        self.channelID = channelID
        self.coreDataService = coreDataService
        self.DBChannel = coreDataService.getDBChannel(channel: channelID)
        self.dataManager = dataManager
        self.imageLoaderService = imageLoaderService
    }
    
    // MARK: - Public properties
    
    weak var presenter: ChannelPresenterProtocol?
    weak var imageLoaderService: ImageLoaderServiceProtocol?
    var handler: (([MessageNetworkModel], ChannelNetworkModel) -> Void)?
    var userName = ""
    var userID = ""
    var eventsSubscribe: Cancellable?
    
    // MARK: - Private properties
    
    private let chatService: ChatServiceProtocol
    private let coreDataService: CoreDataServiceProtocol
    private let DBChannel: ChannelNetworkModel
    private var channelID: String
    private let dataManager: FileManagerServiceProtocol
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
        
        dataManager.readProfilePublisher()
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .decode(type: ProfileModel.self, decoder: JSONDecoder())
            .catch({_ in
                Just(ProfileModel(fullName: nil, statusText: nil, profileImageData: nil))
            })
            .sink(receiveValue: { [weak self] profile in
                self?.userName = profile.fullName ?? ""
                self?.userID = self?.dataManager.userId ?? ""
            })
            .cancel()
                    
            loadFromCoreData(channel: channelID)
            loadFromNetwork(channel: channelID)
    }
    
    func subscribeToSSE() {
        eventsSubscribe = chatService.listenResponses()
            .sink { _ in
            } receiveValue: { [weak self] event in
                guard event.resourceID == self?.channelID else {
                    return
                }
                let id = event.resourceID
                switch event.eventType {
                case .add:
                    break
                case .update:
                    self?.chatService.loadMessagesFrom(channelID: id)
                        .sink { _ in
                        } receiveValue: { [weak self] messages in
                            guard let lastMessage = messages.last else {
                                return
                            }
                            self?.presenter?.uploadMessage(messageModel: lastMessage)
                        }
                        .cancel()
                case .delete:
                    self?.coreDataService.deleteChannel(channelID: id)
                }
            }
    }
    
    func unsubscribeFromSSE() {
        chatService.stopListen()
        eventsSubscribe?.cancel()
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
        })
        .cancel()
    }
    
    func getChannelImage(for channel: ChannelNetworkModel) -> UIImage {
        dataManager.getChannelImage(for: channel)
    }
    
    func getImageForMessage(link: String) -> UIImage {
        guard let placeholder = UIImage(systemName: "photo") else {
            return UIImage()
        }
        return imageLoaderService?.downloadImage(with: link) ?? placeholder
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
