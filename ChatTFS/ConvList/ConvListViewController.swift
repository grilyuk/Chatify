import UIKit
import Combine

enum Section: Hashable, CaseIterable {
    case online
    case offline
}

protocol ConvListViewProtocol: AnyObject {
    func showMain()
    var users: [ConversationListModel]? { get set }
}

class ConvListViewController: UIViewController {
    
    //MARK: - UIConstants
    private enum UIConstants {
        static let rowHeight: CGFloat = 76
        static let sectionHeight: CGFloat = 44
        static let imageSize: CGSize = CGSize(width: 44, height: 44)
        static let smallImageSize: CGSize = CGSize(width: 30, height: 30)
    }
    
    //MARK: - Public
    var presenter: ConvListPresenterProtocol?
    var users: [ConversationListModel]?
    var profileRequest: Cancellable?
    weak var themeService: ThemeServiceProtocol?
    weak var dataManager: DataManagerProtocol?
    
    //MARK: - Private
    private var dataSource: UITableViewDiffableDataSource<Section, ConversationListModel>?
    private lazy var tableView = UITableView()
    private lazy var button = UIButton(type: .custom)
    private lazy var placeholder = UIImage(systemName: "person.fill")?.scalePreservingAspectRatio(targetSize: UIConstants.smallImageSize).withTintColor(.systemBlue)
    
    //MARK: - Initializer
    init(themeService: ThemeServiceProtocol, dataManager: DataManagerProtocol) {
        self.themeService = themeService
        self.dataManager = dataManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Lifeсycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewReady()
        setupNavBar()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = themeService?.currentTheme.backgroundColor
        tableView.backgroundColor = themeService?.currentTheme.backgroundColor
        updateColorsCells()
    }
    
    //MARK: - Setup UI
    private func setupUI() {
        configureTableView()
        setupTableView()
        setupDataSource()
        setupSnapshot()
    }
    
    //MARK: - Methods
    private func setupDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, ConversationListModel> (tableView: tableView) { [weak self]
            (tableView: UITableView, indexPath: IndexPath, itemIdentifier: ConversationListModel) -> ConverstionListCell in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ConverstionListCell.identifier) as? ConverstionListCell,
                  let themeService = self?.themeService
            else { return ConverstionListCell()}
            cell.configureTheme(theme: themeService)
            cell.configure(with: itemIdentifier)
            return cell
        }
    }
    
    private func setupSnapshot() {
        guard let dataSource = dataSource else { return }
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
    
    private func configureTableView() {
        tableView.register(ConverstionListCell.self, forCellReuseIdentifier: ConverstionListCell.identifier)
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupNavBar() {
        navigationItem.title = "Chat"
        let settingButton = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(chooseThemes))
        let profileButton = UIBarButtonItem(customView: button)
        button.addTarget(self, action: #selector(tappedProfile), for: .touchUpInside)
        navigationItem.leftBarButtonItem = settingButton
        navigationItem.rightBarButtonItem = profileButton
        
        navigationController?.navigationBar.prefersLargeTitles = true
        let navBarStyle = UINavigationBarAppearance()
        guard let currentTheme = themeService?.currentTheme else { return }
        switch currentTheme {
        case .light:
            navBarStyle.backgroundColor = currentTheme.backgroundColor
            navBarStyle.titleTextAttributes = [ NSAttributedString.Key.foregroundColor: currentTheme.textColor]
            navBarStyle.largeTitleTextAttributes = [ NSAttributedString.Key.foregroundColor: currentTheme.textColor ]
            changeNavBar(appearance: navBarStyle)
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
        guard let dataSource = dataSource else { return }
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
}

//MARK: - MainViewController + UITableViewDelegate
extension ConvListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UITableViewHeaderFooterView()
        switch section {
        case 0:
            headerView.textLabel?.text = "ONLINE"
        case 1:
            headerView.textLabel?.text = "HISTORY"
        default:
            break
        }
        
        headerView.tintColor = themeService?.currentTheme.backgroundColor
        headerView.textLabel?.textColor = themeService?.currentTheme.incomingTextColor
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        tableView.estimatedSectionHeaderHeight.binade
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UIConstants.rowHeight
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
        guard let dataSource = dataSource else { return }
        let usersInSection = dataSource.snapshot().itemIdentifiers(inSection: section)
        presenter?.didTappedConversation(for: usersInSection[indexPath.row])
    }
}

//MARK: - MainViewController + MainViewProtocol
extension ConvListViewController: ConvListViewProtocol {
    func showMain() {
        setupSnapshot()
        if let imageData = presenter?.profile?.profileImageData {
            button.setBackgroundImage(UIImage(data: imageData), for: .normal)
        } else {
            button.setImage(placeholder, for: .normal)
        }
    }
}
