import Foundation
import UIKit

struct ConversationListModel: Hashable {
    let channelImage: UIImage
    let name: String?
    let message: String?
    let date: Date?
    let isOnline: Bool
    let hasUnreadMessages: Bool?
    let conversationID: String?
    let id = UUID()
}
