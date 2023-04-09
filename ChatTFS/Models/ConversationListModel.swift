import Foundation
import UIKit

struct ChannelModel: Hashable {
    let channelImage: UIImage
    let name: String?
    let message: String?
    let date: Date?
    let isOnline: Bool
    let hasUnreadMessages: Bool?
    let conversationID: String?
    let id = UUID()
}
