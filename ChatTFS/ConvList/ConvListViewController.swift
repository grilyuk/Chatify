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
    
    //MARK: - Initializer
    init(themeService: ThemeServiceProtocol, profilePublisher: CurrentValueSubject<ProfileModel, Never>) {
        self.themeService = themeService
        self.profilePublisher = profilePublisher
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UIConstants
    private enum UIConstants {
        static let rowHeight: CGFloat = 76
        static let sectionHeight: CGFloat = 44
        static let imageSize: CGSize = CGSize(width: 44, height: 44)
    }
    
    //MARK: - Public
    var presenter: ConvListPresenterProtocol?
    var users: [ConversationListModel]?
    var profilePublisher: CurrentValueSubject<ProfileModel, Never>
    var profileRequest: Cancellable?
    weak var themeService: ThemeServiceProtocol?

    //MARK: - Private
    private var dataSource: UITableViewDiffableDataSource<Section, ConversationListModel>?
    private lazy var placeholder = UIImage.placeholder?.scalePreservingAspectRatio(targetSize: UIConstants.imageSize)
    private lazy var tableView = UITableView()
    private lazy var buttonWithUserPhoto = UIButton(type: .custom)
    
    //MARK: - Lifeсycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewReady()
        setupNavigationBar()
        setupUI()
        profileRequest = profilePublisher
            .sink(receiveValue: { profile in
                if let imageData = profile.profileImageData {
                    self.buttonWithUserPhoto.setBackgroundImage(UIImage(data: imageData)?.scalePreservingAspectRatio(targetSize: UIConstants.imageSize), for: .normal)
                } else {
                    self.buttonWithUserPhoto.setBackgroundImage(self.placeholder, for: .normal)
                }
            })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = themeService?.currentTheme.backgroundColor
        tableView.backgroundColor = themeService?.currentTheme.backgroundColor
        navigationController?.navigationBar.prefersLargeTitles = true
        updateColorsCells()
    }
    
    //MARK: - Setup UI
    private func setupUI() {
        configureTableView()
        setupTableViewConstraints()
        setupDataSource()
        setupSnapshot()
    }
    
    //MARK: - Private methods
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
    
    private func setupNavigationBar() {
        let settingButton = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(chooseThemes))
        let profileButton = UIBarButtonItem(customView: buttonWithUserPhoto)
        buttonWithUserPhoto.addTarget(self, action: #selector(tappedProfile), for: .touchUpInside)
        profileButton.customView?.layer.cornerRadius = UIConstants.imageSize.height/2
        profileButton.customView?.clipsToBounds = true
        navigationItem.title = "Chat"
        navigationItem.leftBarButtonItem = settingButton
        navigationItem.rightBarButtonItem = profileButton
        guard let currentTheme = themeService?.currentTheme else { return }
        switch currentTheme {
        case .light: changeNavigationBar(theme: currentTheme)
        case .dark: changeNavigationBar(theme: currentTheme)
        }
    }
    
    private func changeNavigationBar(theme: Theme) {
        guard let currentTheme = themeService?.currentTheme else { return }
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = currentTheme.backgroundColor
        appearance.titleTextAttributes = [ NSAttributedString.Key.foregroundColor: currentTheme.textColor]
        appearance.largeTitleTextAttributes = [ NSAttributedString.Key.foregroundColor: currentTheme.textColor ]
        navigationController?.navigationItem.scrollEdgeAppearance = appearance
        navigationController?.navigationItem.standardAppearance = appearance
        navigationController?.navigationItem.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
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
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    @objc
    private func chooseThemes() {
        presenter?.didTappedThemesPicker()
    }
    
    @objc
    private func tappedProfile() {
        presenter?.didTappedProfile()
    }
    
    private func setupTableViewConstraints() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

//MARK: - ConvListViewController + UITableViewDelegate
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
        UIConstants.sectionHeight
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

//MARK: - ConvListViewController + ConvListViewProtocol
extension ConvListViewController: ConvListViewProtocol {
    func showMain() {
        setupSnapshot()
    }
}
