import UIKit

struct NetworkImageModel: Hashable {
    let uuid = UUID()
    var image: UIImage?
    var isAvailable: Bool
    let link: String
}
