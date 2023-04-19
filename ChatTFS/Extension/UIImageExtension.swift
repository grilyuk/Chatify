import UIKit

extension UIImage {
    
    static let placeholder = UIImage(systemName: "person.fill")?
        .withTintColor(.systemGray, renderingMode: .alwaysOriginal)
    static let channelPlaceholder = UIImage(systemName: "person.2.circle")?
        .withTintColor(.systemGray, renderingMode: .alwaysOriginal) ?? UIImage()
    
    func scalePreservingAspectRatio(targetSize: CGSize) -> UIImage {
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        let scaleFactor = min(widthRatio, heightRatio)
        
        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )

        let renderer = UIGraphicsImageRenderer(
            size: scaledImageSize
        )

        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(
                origin: .zero,
                size: scaledImageSize
            ))
        }
        return scaledImage
    }
}
