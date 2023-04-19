import Foundation
import TFSChatTransport
import Combine

protocol ChatServiceProtocol {
    func loadChannels() -> AnyPublisher<[ChannelNetworkModel], Error>
    func createChannel(channelName: String) -> AnyPublisher<ChannelNetworkModel, Error>
    func deleteChannel(id: String) -> AnyPublisher<Void, Error>
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
}
