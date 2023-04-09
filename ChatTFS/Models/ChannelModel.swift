import Foundation
import UIKit

struct ChannelModel: Hashable {
    let channelImage: UIImage
    let name: String?
    let message: String?
    let date: Date?
    let isOnline: Bool
    let hasUnreadMessages: Bool?
    let channelID: String?
    let uuid = UUID()
}

struct ChannelNetworkModel: Hashable {
    let id: String
    let name: String
    let logoURL: String?
    let lastMessage: String?
    let lastActivity: Date?
}
