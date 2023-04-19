import Foundation
import TFSChatTransport

struct ChannelNetworkModel: Hashable {
    
    init(from channel: Channel) {
        self.id = channel.id
        self.name = channel.name
        self.logoURL = channel.logoURL
        self.lastMessage = channel.lastMessage
        self.lastActivity = channel.lastActivity
    }
    
    init(id: String, name: String, logoURL: String?, lastMessage: String?, lastActivity: Date?) {
        self.id = id
        self.name = name
        self.logoURL = logoURL
        self.lastMessage = lastMessage
        self.lastActivity = lastActivity
    }
    
    let id: String
    let name: String
    let logoURL: String?
    let lastMessage: String?
    let lastActivity: Date?
}
