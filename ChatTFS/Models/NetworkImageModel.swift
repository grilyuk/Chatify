import UIKit

struct NetworkImageModel: Hashable {
    let uuid = UUID()
    var image: UIImage = UIImage.imagePlaceholder
    var isAvailable: Bool
    let link: String
    var isUploaded: Bool
}
