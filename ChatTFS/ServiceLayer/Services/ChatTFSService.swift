import Foundation
import TFSChatTransport
import Combine

protocol ChatServiceProtocol {
    func loadChannels() -> AnyPublisher<[ChannelNetworkModel], Error>
    func loadChannel(id: String) -> AnyPublisher<ChannelNetworkModel, Error>
    func createChannel(channelName: String) -> AnyPublisher<ChannelNetworkModel, Error>
    func deleteChannel(id: String) -> AnyPublisher<Void, Error>
    func createMessageData(messageText: String, channelID: String, userID: String, userName: String) -> AnyPublisher<MessageNetworkModel, Error>
    func loadMessagesFrom(channelID: String) -> AnyPublisher<[MessageNetworkModel], Error>
    func listenResponses() -> AnyPublisher<ChatEvent, Error>
    func stopListen()
}

final class ChatTFSService: ChatServiceProtocol {
    
    // MARK: - Initialization
    
    init(chatTFS: ChatTFS) {
        self.chatTFS = chatTFS
    }
    
    // MARK: - Private properties
    
    private let chatTFS: ChatTFS
    var SSEService: SSEService?
    private let mainQueue = DispatchQueue.main
    private let backgroundQueue = DispatchQueue.global(qos: .utility)
    
    // MARK: - Public methods
    
    func listenResponses() -> AnyPublisher<ChatEvent, Error> {
        SSEService = TFSChatTransport.SSEService(host: chatTFS.chatHost, port: chatTFS.chatPort)
        return SSEService?.subscribeOnEvents() ?? chatTFS.chatSSE.subscribeOnEvents()
    }
    
    func stopListen() {
        SSEService?.cancelSubscription()
    }
    
    func loadChannel(id: String) -> AnyPublisher<ChannelNetworkModel, Error> {
        chatTFS.chatServer.loadChannel(id: id)
            .subscribe(on: backgroundQueue)
            .receive(on: mainQueue)
            .map { channel in
                return ChannelNetworkModel(id: channel.id,
                                           name: channel.name,
                                           logoURL: channel.logoURL,
                                           lastMessage: channel.lastMessage,
                                           lastActivity: channel.lastActivity)
            }
            .eraseToAnyPublisher()
    }
    
    func loadChannels() -> AnyPublisher<[ChannelNetworkModel], Error> {
        chatTFS.chatServer.loadChannels()
            .subscribe(on: backgroundQueue)
            .receive(on: mainQueue)
            .map { channels in
                let channelModels: [ChannelNetworkModel] = channels
                    .map { ChannelNetworkModel(from: $0) }
                
                return channelModels
            }
            .eraseToAnyPublisher()
    }
    
    func createChannel(channelName: String) -> AnyPublisher<ChannelNetworkModel, Error> {
        chatTFS.chatServer.createChannel(name: channelName)
            .subscribe(on: backgroundQueue)
            .receive(on: mainQueue)
            .map({ channel in
                return ChannelNetworkModel(from: channel)
            })
            .eraseToAnyPublisher()
    }
    
    func deleteChannel(id: String) -> AnyPublisher<Void, Error> {
        chatTFS.chatServer.deleteChannel(id: id)
            .subscribe(on: backgroundQueue)
            .receive(on: mainQueue)
            .map({ _ in return })
            .eraseToAnyPublisher()
    }
    
    func loadMessagesFrom(channelID: String) -> AnyPublisher<[MessageNetworkModel], Error> {
        chatTFS.chatServer.loadMessages(channelId: channelID)
            .subscribe(on: backgroundQueue)
            .receive(on: mainQueue)
            .map({ messages in
                let messageModels: [MessageNetworkModel] = messages
                    .map { MessageNetworkModel(from: $0) }
                
                return messageModels
            })
            .eraseToAnyPublisher()
    }
    
    func createMessageData(messageText: String, channelID: String, userID: String, userName: String) -> AnyPublisher<MessageNetworkModel, Error> {
        chatTFS.chatServer.sendMessage(text: messageText,
                                                      channelId: channelID,
                                                      userId: userID,
                                                      userName: userName)
        .subscribe(on: backgroundQueue)
        .receive(on: mainQueue)
        .map({ message in
            MessageNetworkModel(from: message)
        })
        .eraseToAnyPublisher()
    }
}
