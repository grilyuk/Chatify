import Foundation
import TFSChatTransport

struct MessageNetworkModel: Hashable {
    
    init(from message: Message) {
        self.id = message.id
        self.text = message.text
        self.userID = message.userID
        self.userName = message.userName
        self.date = message.date
    }
    
    init(id: String = "", text: String = "", userID: String = "", userName: String = "", date: Date = Date()) {
        self.id = id
        self.text = text
        self.userID = userID
        self.userName = userID
        self.date = date
    }
    
    let id: String
    let text: String
    let userID: String
    let userName: String
    let date: Date
}
