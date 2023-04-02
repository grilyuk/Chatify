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
    
    // MARK: - Initialization
    
    init(themeService: ThemeServiceProtocol) {
        self.themeService = themeService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIConstants
    
    private enum UIConstants {
        static let rowHeight: CGFloat = 76
        static let sectionHeight: CGFloat = 44
        static let imageSize: CGSize = CGSize(width: 44, height: 44)
    }
    
    // MARK: - Public
    
    var presenter: ConvListPresenterProtocol?
    var users: [ConversationListModel]?
    weak var themeService: ThemeServiceProtocol?

    // MARK: - Private
    
    private var dataSource: UITableViewDiffableDataSource<Int, ConversationListModel>?
    private lazy var placeholder = UIImage.placeholder?.scalePreservingAspectRatio(targetSize: UIConstants.imageSize)
    private lazy var tableView = UITableView()
    private lazy var buttonWithUserPhoto = UIButton(type: .custom)
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewReady()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = themeService?.currentTheme.backgroundColor
        tableView.backgroundColor = themeService?.currentTheme.backgroundColor
        navigationController?.navigationBar.prefersLargeTitles = true
        tabBarController?.tabBar.isHidden = false
        updateColorsCells()
        setupNavigationBar()
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        configureTableView()
        setupTableViewConstraints()
        setupDataSource()
        setupSnapshot()
    }
    
    // MARK: - Private methods
    
    private func setupDataSource() {
        dataSource = UITableViewDiffableDataSource(tableView: tableView, cellProvider: { [weak self] tableView, _, itemIdentifier in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ConversationListCell.identifier) as? ConversationListCell,
                  let themeService = self?.themeService
            else { return ConversationListCell()}
            cell.configureTheme(theme: themeService)
            cell.configure(with: itemIdentifier)
            return cell
        })
    }
    
    private func setupSnapshot() {
        guard let dataSource = dataSource else { return }
        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()
        guard let users = users else { return }
        snapshot.appendSections([0])
        snapshot.appendItems(users, toSection: 0)
        dataSource.apply(snapshot)
    }
    
    private func configureTableView() {
        tableView.register(ConversationListCell.self, forCellReuseIdentifier: ConversationListCell.identifier)
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Channels"
        let addChannelButton = UIBarButtonItem(title: "Add Channel", style: .plain, target: self, action: nil)
        navigationItem.rightBarButtonItem = addChannelButton
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
        snapshot.itemIdentifiers.forEach { item in
            snapshot.reloadItems([item])
        }
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func setupTableViewConstraints() {
        view.addSubviews(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

// MARK: - ConvListViewController + UITableViewDelegate

extension ConvListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        UIConstants.sectionHeight
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UIConstants.rowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let users = users,
              let navigationController = navigationController else {return}
        presenter?.didTappedConversation(for: users[indexPath.row], navigationController: navigationController)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - ConvListViewController + ConvListViewProtocol

extension ConvListViewController: ConvListViewProtocol {
    func showMain() {
        setupSnapshot()
    }
}
