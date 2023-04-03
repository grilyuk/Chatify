import Foundation

struct ConversationListModel: Hashable {
    let channelImage: String?
    let name: String?
    let message: String?
    let date: Date?
    let isOnline: Bool
    let hasUnreadMessages: Bool?
    let id = UUID()
}
