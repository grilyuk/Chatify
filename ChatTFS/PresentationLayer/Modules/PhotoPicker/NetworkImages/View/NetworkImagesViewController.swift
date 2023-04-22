import UIKit

protocol NetworkImagesViewProtocol: AnyObject {
    func showNetworkImages()
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
        view.addSubview(imagesCollectionView)
        imagesCollectionView.register(NetworkImagesCell.self, forCellWithReuseIdentifier: NetworkImagesCell.identifier)
        setupUI()
    }
    
    // MARK: - Private properties
    
    private func setupUI() {
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
        print(indexPath)
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
    func showNetworkImages() {
        let array: [NetworkImageModel] = [NetworkImageModel(),
                                          NetworkImageModel(),
                                          NetworkImageModel(),
                                          NetworkImageModel(),
                                          NetworkImageModel()]
        dataSource.reload(images: array)
    }
}
