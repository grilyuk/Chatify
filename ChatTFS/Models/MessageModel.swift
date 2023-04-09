import Foundation

struct MessageModel: Hashable {
    let text: String
    let date: Date
    let myMessage: Bool
    let userName: String
    let isSameUser: Bool
    let uuid = UUID()
}

public struct MessageNetworkModel: Hashable {
    let id: String
    let text: String
    let userID: String
    let userName: String
    let date: Date
}
