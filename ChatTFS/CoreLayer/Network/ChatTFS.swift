import Foundation
import TFSChatTransport

protocol ChatProtocol: AnyObject {
    var chatServer: ChatService { get }
    var chatSSE: SSEService { get }
}

final class ChatTFS: ChatProtocol {
    
    // MARK: - Private properties
    
    var chatHost = "167.235.86.234"
    var chatPort = 8080
    
    // MARK: - Public properties
    
    lazy var chatServer = ChatService(host: chatHost, port: chatPort)
    lazy var chatSSE = SSEService(host: chatHost, port: chatPort)
}
