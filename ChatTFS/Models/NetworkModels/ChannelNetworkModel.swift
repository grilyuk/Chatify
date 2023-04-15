import Foundation
import UIKit

struct ChannelNetworkModel: Hashable {
    let id: String
    let name: String
    let logoURL: String?
    let lastMessage: String?
    let lastActivity: Date?
}
