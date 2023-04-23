import Foundation
import UIKit

struct ChannelModel: Hashable {
    let channelImage: UIImage
    let name: String?
    var message: String?
    var date: Date?
    let isOnline: Bool
    let hasUnreadMessages: Bool?
    let channelID: String?
    let uuid = UUID()
}
