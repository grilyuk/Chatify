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
    weak var dataManager: DataManagerProtocol?
    var coreDataService: CoreDataServiceProtocol
    var dataHandler: (([MessageNetworkModel], ChannelNetworkModel) -> Void)?
    
    // MARK: - Private properties
    
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
        
        guard
            let channelID
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
            self?.saveMessagesForChannel(for: channelID,
                                         messages: [MessageNetworkModel(id: message.id,
                                                                        text: messageText,
                                                                        userID: userID,
                                                                        userName: userName,
                                                                        date: message.date)])
            self?.presenter?.uploadMessage(messageModel: message)
        })
    }
    
    // MARK: - Private methods
    
    private func loadFromCoreData(channel: String) {
        
        do {
            let messagesDB = try coreDataService.fetchChannelMessages(for: channel)
            let channelDB = try coreDataService.fetchChannel(for: channel)
            let messages: [MessageNetworkModel] = messagesDB
                .compactMap { messagesBD in
                    guard
                        let id = messagesBD.id,
                        let text = messagesBD.text,
                        let userID = messagesBD.userID,
                        let userName = messagesBD.userName,
                        let date = messagesBD.date
                    else {
                        return MessageNetworkModel(id: "",
                                                   text: "",
                                                   userID: "",
                                                   userName: "",
                                                   date: Date())
                    }
                    return MessageNetworkModel(id: id,
                                               text: text,
                                               userID: userID,
                                               userName: userName,
                                               date: date)
                }
            
            guard
                let id = channelDB.id,
                let name = channelDB.name
            else {
                return
            }
            
            let channelNetworkModel = ChannelNetworkModel(id: id,
                                                          name: name,
                                                          logoURL: nil,
                                                          lastMessage: nil,
                                                          lastActivity: nil)
            sentMessages.append(contentsOf: messages)
            dataHandler?(sentMessages, channelNetworkModel)
        } catch {
            print(error.localizedDescription)
        }
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
                
                var networkMessages = messagesData
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
                
                self?.saveMessagesForChannel(for: channelID,
                                             messages: messagesToSave)
                self?.dataHandler?(networkMessages, networkChannelModel)
                self?.presenter?.dataUploaded()
            })
    }
    
    private func saveMessagesForChannel(for channelID: String, messages: [MessageNetworkModel]) {
        let loggerText = "Messages saving from channel \(channelID)"
        coreDataService.save(loggerText: loggerText) { context in
            let fetchRequest = DBChannel.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", channelID)
            let channelManagedObject = try context.fetch(fetchRequest).first
            
            guard
                let channelManagedObject
            else {
                return
            }
            
            for message in messages {
                let messageManagedObject = DBMessage(context: context)
                messageManagedObject.id = message.id
                messageManagedObject.date = message.date
                messageManagedObject.text = message.text
                messageManagedObject.userID = message.userID
                messageManagedObject.userName = message.userName
                channelManagedObject.lastMessage = message.text
                channelManagedObject.lastActivity = message.date
                channelManagedObject.addToMessages(messageManagedObject)
            }
            
            channelManagedObject.lastMessage = messages.last?.text
            channelManagedObject.lastActivity = messages.last?.date
        }
    }
}
