import Foundation
import TFSChatTransport

protocol ChatProtocol: AnyObject {
    var chatServer: ChatService { get }
}

final class ChatTFS: ChatProtocol {
    
    // MARK: - Private properties
    
    private var chatHost = "167.235.86.234"
    private var chatPort = 8080
    
    // MARK: - Public properties
    
    lazy var chatServer = ChatService(host: chatHost, port: chatPort)
}
