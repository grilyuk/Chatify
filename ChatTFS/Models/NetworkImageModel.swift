import UIKit

struct NetworkImageModel: Hashable {
    let uuid = UUID()
    var image: UIImage = UIImage(systemName: "photo")?
        .withTintColor(.lightGray, renderingMode: .alwaysOriginal) ?? UIImage()
    var isAvailable: Bool
    let link: String
}
