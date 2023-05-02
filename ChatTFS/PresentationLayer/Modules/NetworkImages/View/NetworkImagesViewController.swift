import UIKit

protocol NetworkImagesViewProtocol: AnyObject {
    var images: [NetworkImageModel] { get set }
    func showNetworkImages()
    func updateImageInCell(uuid: UUID)
}

class NetworkImagesViewController: UIViewController {
    
    typealias DataSource = UICollectionViewDiffableDataSource<Int, UUID>
    
    // MARK: - Initialization
    
    init(themeService: ThemeServiceProtocol) {
        self.themeService = themeService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public properties
    
    var images: [NetworkImageModel] = []
    var presenter: NetworkImagesPresenterProtocol?
    weak var vc: UIViewController?
    weak var themeService: ThemeServiceProtocol?
    
    // MARK: - Private properties
    
    private lazy var dataSource = DataSource(collectionView: collectionView) { [weak self] collectionView, indexPath, uuid in
        guard let model = self?.images.first(where: { $0.uuid == uuid }),
              let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NetworkImagesCell.identifier, for: indexPath) as? NetworkImagesCell
        else {
            return NetworkImagesCell()
        }
        cell.configure(with: model)
        
        return cell
    }
    
    private var collectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let collection = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: layout)
        return collection
    }()
    
    private lazy var activityIndicator = UIActivityIndicatorView(style: .medium)

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewReady()
        collectionView.delegate = self
        collectionView.dataSource = dataSource
        collectionView.register(NetworkImagesCell.self, forCellWithReuseIdentifier: NetworkImagesCell.identifier)
        collectionView.backgroundColor = themeService?.currentTheme.backgroundColor
        activityIndicator.startAnimating()
        setupNavigationBar()
        setupUI()
    }
    
    // MARK: - Private properties
    
    private func setupNavigationBar() {
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(close))
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.title = "Choose image"
        navigationController?.navigationBar.backgroundColor = themeService?.currentTheme.backgroundColor
    }
    
    @objc
    private func close() {
        self.dismiss(animated: true) { [weak self] in
            self?.images.removeAll()
            self?.presenter?.uploadedImages.removeAll()
        }
    }
    
    private func setupUI() {
        view.addSubviews(collectionView, activityIndicator)
        
        view.backgroundColor = themeService?.currentTheme.backgroundColor
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

extension NetworkImagesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = dataSource.snapshot().itemIdentifiers[indexPath.row]
        guard let index = images.firstIndex(where: { $0.uuid == item }),
              images[index].isAvailable
        else {
            return
        }
        if let profileVC = vc as? EditProfileViewController {
            profileVC.profilePhoto.image = images[index].image
        } else if let channelVC = vc as? ChannelViewProtocol {
            channelVC.setImageMessage(link: images[index].link)
        }
        dismiss(animated: true) { [weak self] in
            self?.images.removeAll()
            self?.presenter?.uploadedImages.removeAll()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        DispatchQueue.global().sync { [weak self] in
            if let index = self?.dataSource.itemIdentifier(for: indexPath),
                  let model = self?.images.first(where: { $0.uuid == index }),
               !model.isAvailable,
               !model.isUploaded {
                self?.presenter?.loadImage(for: index, url: model.link)
            }
        }
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
        activityIndicator.stopAnimating()
        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()
        snapshot.appendSections([0])
        snapshot.appendItems(images.map({ $0.uuid }))
        dataSource.apply(snapshot)
    }
    
    func updateImageInCell(uuid: UUID) {
        var snapshot = dataSource.snapshot()
        snapshot.reloadItems([uuid])
        dataSource.apply(snapshot)
    }
}
