import UIKit

protocol ConvListViewProtocol: AnyObject {
    func showMain()
    var users: [ConversationListModel]? { get set }
    var handler:(([ConversationListModel]) -> Void)? { get set }
}

class ConvListViewController: UIViewController {
    
    //MARK: - UIConstants
    private enum UIConstants {
        static let rowHeight: CGFloat = 76
        static let sectionHeight: CGFloat = 44
        static let imageSize: CGSize = CGSize(width: 44, height: 44)
    }
    
    //MARK: - Public
    var presenter: ConvListPresenterProtocol?
    var users: [ConversationListModel]?
    var handler: (([ConversationListModel]) -> Void)?
    weak var themeService: ThemeServiceProtocol?
    
    //MARK: - Private
    private lazy var profileImageView = UIImageView()
    // извиняюсь за force unwrap, честно, не осталось времени подумать как его убрать
    private lazy var dataSource = ConvListDataSource(tableView: tableView, themeService: themeService!)
    private lazy var tableView = UITableView()
    private lazy var button = UIButton(type: .custom)
    
    //MARK: - Lifeсycle
    init(themeService: ThemeServiceProtocol) {
        self.themeService = themeService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewReady()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavBar()
        updateColorsCells()
    }
    
    //MARK: - Setup UI
    private func setupUI() {
        setTableView()
        setDataSource()
    }
    
    //MARK: - Methods
    private func setTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ConverstionListCell.self, forCellReuseIdentifier: ConverstionListCell.identifier)
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setNavBar() {
        navigationItem.title = "Chat"
        
        let settingButton = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(chooseThemes))
        navigationItem.leftBarButtonItem = settingButton
        
        button.addTarget(self, action: #selector(tappedProfile), for: .touchUpInside)
        button.contentMode = .scaleToFill
        let profileButton = UIBarButtonItem(customView: button)
        profileButton.customView?.contentMode = .scaleAspectFill
        profileButton.customView?.frame = CGRect(origin: .zero, size: UIConstants.imageSize)
        profileButton.customView?.layer.cornerRadius = UIConstants.imageSize.height / 2
        profileButton.customView?.clipsToBounds = true
        navigationItem.rightBarButtonItem = profileButton
        
        navigationController?.navigationBar.prefersLargeTitles = true
        let navBarStyle = UINavigationBarAppearance()
        guard let currentTheme = themeService?.currentTheme else { return }
        switch currentTheme {
        case .light:
            navBarStyle.backgroundColor = currentTheme.backgroundColor
            navBarStyle.titleTextAttributes = [ NSAttributedString.Key.foregroundColor: currentTheme.textColor]
            navBarStyle.largeTitleTextAttributes = [ NSAttributedString.Key.foregroundColor: currentTheme.textColor ]
        case .dark:
            navBarStyle.backgroundColor = currentTheme.backgroundColor
            navBarStyle.titleTextAttributes = [ NSAttributedString.Key.foregroundColor: currentTheme.textColor]
            navBarStyle.largeTitleTextAttributes = [ NSAttributedString.Key.foregroundColor: currentTheme.textColor ]
            changeNavBar(appearance: navBarStyle)
        }
    }
    
    private func changeNavBar(appearance: UINavigationBarAppearance) {
        navigationController?.navigationItem.scrollEdgeAppearance = appearance
        navigationController?.navigationItem.standardAppearance = appearance
        navigationController?.navigationItem.compactAppearance = appearance
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    private func updateColorsCells() {
        var snapshot = dataSource.snapshot()
        snapshot.sectionIdentifiers.forEach { section in
            snapshot.reloadSections([section])
        }
        snapshot.itemIdentifiers.forEach { item in
            snapshot.reloadItems([item])
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    @objc
    private func chooseThemes() {
        presenter?.didTappedThemesPicker()
    }
    
    @objc
    private func tappedProfile() {
        presenter?.didTappedProfile()
    }
    
    //MARK: - SetDataSource
    private func setDataSource() {
        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()
        snapshot.appendSections([Section.online, Section.offline])
        guard let users = users else { return }
        for user in users {
            switch user.isOnline {
            case true:
                snapshot.appendItems([user], toSection: .online)
            case false:
                snapshot.appendItems([user], toSection: .offline)
            }
        }
        dataSource.apply(snapshot)
    }
}

//MARK: - MainViewController + UITableViewDelegate
extension ConvListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        UIConstants.sectionHeight
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UIConstants.rowHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.tintColor = themeService?.currentTheme.backgroundColor
            headerView.textLabel?.textColor = themeService?.currentTheme.incomingTextColor
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var section = Section.offline
        switch indexPath.section {
        case 0:
            section = .online
        case 1:
            section = .offline
        default:
            break
        }
        let usersInSection = dataSource.snapshot().itemIdentifiers(inSection: section)
        presenter?.didTappedConversation(for: usersInSection[indexPath.row])
    }
}

//MARK: - MainViewController + MainViewProtocol
extension ConvListViewController: ConvListViewProtocol {
    func showMain() {
        handler = { [weak self] value in
            self?.users = value
            self?.setDataSource()
        }
        view.backgroundColor = themeService?.currentTheme.backgroundColor
        tableView.backgroundColor = themeService?.currentTheme.backgroundColor
        guard let imageData = self.presenter?.profile?.profileImageData else { return }
        let imageButton = UIImage(data: imageData)?.scalePreservingAspectRatio(targetSize: UIConstants.imageSize)
        button.setImage(imageButton, for: .normal)
    }
}

//MARK: - MainViewController + DataManagerSubscriber
extension ConvListViewController: DataManagerSubscriber {
    func updateProfile(profile: ProfileModel) {
        presenter?.profile = profile
        if profile.profileImageData == nil {
            button.setImage(UIImage(systemName: "heart"), for: .normal)
        } else {
            guard let imageData = profile.profileImageData else { return }
            let image = UIImage(data: imageData)
            button.setImage(image?.scalePreservingAspectRatio(targetSize: UIConstants.imageSize), for: .normal)
        }
    }
}
