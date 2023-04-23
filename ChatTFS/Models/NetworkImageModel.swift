import UIKit

struct NetworkImageModel: Hashable {
    let uuid = UUID()
    let image: UIImage
    let isAvailable: Bool
}
