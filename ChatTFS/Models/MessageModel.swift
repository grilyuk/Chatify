import Foundation

struct MessageModel: Hashable {
    let text: String
    let date: Date
    let myMessage: Bool
    let userName: String
    let isSameUser: Bool
    let uuid = UUID()
}
