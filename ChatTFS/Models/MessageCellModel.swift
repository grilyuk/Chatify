import Foundation

struct MessageCellModel: Hashable {
    let text: String
    let date: Date
    let myMessage: Bool
    let id = UUID()
}
