import UIKit

protocol NetworkImagesViewProtocol: AnyObject {
    func showNetworkImages(images: [NetworkImageModel])
}

class NetworkImagesViewController: UIViewController {
    
    // MARK: - Initialization
    
    init() {
        self.dataSource = NetworkImagesDataSource(collectionView: imagesCollectionView)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public properties
    
    var presenter: NetworkImagesPresenterProtocol?
    weak var profileVC: ProfileViewProtocol?
    
    // MARK: - Private properties
    
    private let dataSource: NetworkImagesDataSource
    
    private var imagesCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let collection = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: layout)
        return collection
    }()

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewReady()
        imagesCollectionView.delegate = self
        imagesCollectionView.dataSource = dataSource
        imagesCollectionView.register(NetworkImagesCell.self, forCellWithReuseIdentifier: NetworkImagesCell.identifier)
        setupNavigationBar()
        setupUI()
    }
    
    // MARK: - Private properties
    
    private func setupNavigationBar() {
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(close))
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.title = "Choose image"
    }
    
    @objc
    private func close() {
        dismiss(animated: true)
    }
    
    private func setupUI() {
        view.addSubview(imagesCollectionView)
        
        imagesCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imagesCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
            imagesCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            imagesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imagesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

extension NetworkImagesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let items = dataSource.snapshot().itemIdentifiers
        guard let profileVC = profileVC as? ProfileViewController,
              items[indexPath.row].isAvailable
        else {
            return
        }
        profileVC.profilePhoto.image = items[indexPath.row].image
        dismiss(animated: true)
    }
}

extension NetworkImagesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let width = collectionView.bounds.width / 3
            return CGSize(width: width, height: width)
        }
}

// MARK: - NetworkImagesViewController + NetworkImagesViewProtocol

extension NetworkImagesViewController: NetworkImagesViewProtocol {
    func showNetworkImages(images: [NetworkImageModel]) {
        dataSource.reload(images: images)
    }
}
