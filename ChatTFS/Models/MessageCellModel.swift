import Foundation

struct MessageCellModel: Hashable {
    let text: String
    let date: Date
    let myMessage: Bool
    let userName: String
    let id = UUID()
}
