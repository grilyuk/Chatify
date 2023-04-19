import Foundation
import TFSChatTransport
import Combine

protocol ChatServiceProtocol {
    func loadChannels() -> AnyPublisher<[ChannelNetworkModel], Error>
    func createChannel(channelName: String) -> AnyPublisher<ChannelNetworkModel, Error>
    func deleteChannel(id: String) -> AnyPublisher<Void, Error>
    func createMessageData(messageText: String, channelID: String, userID: String, userName: String) -> AnyPublisher<MessageNetworkModel, Error>
    func loadMessagesFrom(channelID: String) -> AnyPublisher<[MessageNetworkModel], Error>
}

final class ChatTFSService: ChatServiceProtocol {
    
    // MARK: - Initialization
    
    init(chatTFS: ChatTFS) {
        self.chatTFS = chatTFS
    }
    
    // MARK: - Private properties
    
    private let chatTFS: ChatTFS
    private let mainQueue = DispatchQueue.main
    private let backgroundQueue = DispatchQueue.global(qos: .utility)
    
    // MARK: - Public methods
    
    func loadChannels() -> AnyPublisher<[ChannelNetworkModel], Error> {
        return chatTFS.chatServer.loadChannels()
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
        return chatTFS.chatServer.createChannel(name: channelName)
            .subscribe(on: backgroundQueue)
            .receive(on: mainQueue)
            .map({ channel in
                return ChannelNetworkModel(from: channel)
            })
            .eraseToAnyPublisher()
    }
    
    func deleteChannel(id: String) -> AnyPublisher<Void, Error> {
        return chatTFS.chatServer.deleteChannel(id: id)
            .subscribe(on: backgroundQueue)
            .receive(on: mainQueue)
            .map({ _ in return })
            .eraseToAnyPublisher()
    }
    
    func loadMessagesFrom(channelID: String) -> AnyPublisher<[MessageNetworkModel], Error> {
        return chatTFS.chatServer.loadMessages(channelId: channelID)
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
        return chatTFS.chatServer.sendMessage(text: messageText,
                                                      channelId: channelID,
                                                      userId: userID,
                                                      userName: userName)
        .subscribe(on: backgroundQueue)
        .receive(on: mainQueue)
        .map({ message in
            return MessageNetworkModel(from: message)
        })
        .eraseToAnyPublisher()
    }
}
