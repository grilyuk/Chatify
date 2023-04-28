import UIKit

struct MessageModel: Hashable {
    var image: UIImage?
    let text: String
    let date: Date
    let myMessage: Bool
    let userName: String
    let isSameUser: Bool
    let id: String
    let uuid = UUID()
}
