import UIKit

class NetworkImagesCell: UICollectionViewCell {
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public properties
    
    static let identifier = String(describing: NetworkImagesCell.self)
    
    // MARK: - Private properties
    
    private enum UIConstants {
        static let edges: CGFloat = 5
    }
    
    private lazy var imageAvatar: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    // MARK: - Private methods
    
    private func setupUI() {
        contentView.addSubview(imageAvatar)
        
        imageAvatar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageAvatar.topAnchor.constraint(equalTo: contentView.topAnchor, constant: UIConstants.edges),
            imageAvatar.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -UIConstants.edges),
            imageAvatar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: UIConstants.edges),
            imageAvatar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -UIConstants.edges)
        ])
    }
    
    // MARK: - Public methods
    
    func configure(with model: NetworkImageModel) {
        if model.image == nil {
            imageAvatar.image = UIImage(systemName: "photo")?.withTintColor(.lightGray, renderingMode: .alwaysOriginal)
        } else {
            imageAvatar.image = model.image
        }
    }
}
