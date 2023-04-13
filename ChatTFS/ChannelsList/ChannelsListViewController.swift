import UIKit
import Combine

protocol ChannelsListViewProtocol: AnyObject {
    func showChannelsList()
    func showAlert()
    func addChannel(channel: ChannelModel)
    var channels: [ChannelModel]? { get set }
}

class ChannelsListViewController: UIViewController {
    
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
    
    var presenter: ChannelsListPresenterProtocol?
    var channels: [ChannelModel]?
    weak var themeService: ThemeServiceProtocol?
    var pullToRefresh = UIRefreshControl()

    // MARK: - Private
    
    private var dataSource: UITableViewDiffableDataSource<Int, ChannelModel>?
    private lazy var placeholder = UIImage.placeholder?.scalePreservingAspectRatio(targetSize: UIConstants.imageSize)
    private lazy var tableView = UITableView()
    private lazy var buttonWithUserPhoto = UIButton(type: .custom)
    private lazy var errorAlert = UIAlertController(title: "Ошибка", message: "Что-то пошло не так", preferredStyle: .alert)
    private lazy var cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
    private lazy var retryAction = UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
        self?.presenter?.viewReady()
    }
    private lazy var activityIndicator = UIActivityIndicatorView(style: .medium)
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewReady()
        pullToRefresh.addTarget(self, action: #selector(updateChannelList), for: .valueChanged)
        setupUI()
        activityIndicator.startAnimating()
        errorAlert.addAction(retryAction)
        errorAlert.addAction(cancelAction)
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
    }
    
    // MARK: - Private methods
    
    private func setupDataSource() {
        dataSource = UITableViewDiffableDataSource(tableView: tableView, cellProvider: { [weak self] tableView, _, itemIdentifier in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ChannelListCell.identifier) as? ChannelListCell,
                  let themeService = self?.themeService
            else { return ChannelListCell()}
            cell.configureTheme(theme: themeService)
            cell.configure(with: itemIdentifier)
            return cell
        })
    }
    
    private func setupSnapshot() {
        guard let dataSource = dataSource else { return }
        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()
        guard let channels = channels else { return }
        snapshot.appendSections([0])
        snapshot.appendItems(channels, toSection: 0)
        dataSource.apply(snapshot)
    }
    
    private func configureTableView() {
        tableView.register(ChannelListCell.self, forCellReuseIdentifier: ChannelListCell.identifier)
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        tableView.addSubview(pullToRefresh)
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Channels"
        let addChannelButton = UIBarButtonItem(title: "Add Channel", style: .plain, target: self, action: #selector(addChannelTapped))
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
    
    private func showCreateChannelAC() {
        let addChanelAlert = UIAlertController(title: "New channel", message: nil, preferredStyle: .alert)
        addChanelAlert.addTextField()
        addChanelAlert.textFields?.first?.placeholder = "Channel Name"

        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let createChannel = UIAlertAction(title: "Create", style: .default) { [weak addChanelAlert, weak self] _ in
            guard let textFieldIsEmpty = addChanelAlert?.textFields?.first?.text?.isEmpty
            else {
                return
            }
            if textFieldIsEmpty {
                let errorAlert = UIAlertController(title: "Channel name empty!",
                                                   message: "Имя канала не может быть пустым. \nВведите имя канала.",
                                                   preferredStyle: .alert)
                let action = UIAlertAction(title: "Retry", style: .cancel) { [weak self] _ in
                    self?.showCreateChannelAC()
                }
                errorAlert.addAction(action)
                self?.present(errorAlert, animated: true)
            } else {
                guard let channelName = addChanelAlert?.textFields?.first?.text
                else {
                    return
                }
                self?.presenter?.createChannel(name: channelName)
            }
        }
        addChanelAlert.addAction(cancel)
        addChanelAlert.addAction(createChannel)
        present(addChanelAlert, animated: true)
    }
    
    private func setupTableViewConstraints() {
        view.addSubviews(tableView, activityIndicator)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc
    private func addChannelTapped() {
        showCreateChannelAC()
    }
    
    @objc
    private func updateChannelList() {
        presenter?.viewReady()
    }
}

// MARK: - ChannelsListViewController + UITableViewDelegate

extension ChannelsListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        UIConstants.sectionHeight
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UIConstants.rowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let navigationController = navigationController,
              let snapshot = dataSource?.snapshot(),
              let channelID = snapshot.itemIdentifiers[indexPath.item].channelID
        else {return}
        presenter?.didTappedChannel(to: channelID, navigationController: navigationController)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completion) in
            
            guard
                let self,
                var snapshot = self.dataSource?.snapshot()
            else {
                return
                
            }
            
            let identifiers = snapshot.itemIdentifiers
            snapshot.deleteItems([identifiers[indexPath.row]])
            guard let resultOfDeleting = self.presenter?.deleteChannel(id: identifiers[indexPath.row].channelID ?? "") else { return }
            if resultOfDeleting {
                self.dataSource?.apply(snapshot)
            } else {
                return
            }
            completion(false)
        }
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
}

// MARK: - ChannelsListViewController + ChannelsListViewProtocol

extension ChannelsListViewController: ChannelsListViewProtocol {
    
    func showChannelsList() {
        setupDataSource()
        setupSnapshot()
        pullToRefresh.endRefreshing()
        activityIndicator.stopAnimating()
    }
    
    func showAlert() {
        if errorAlert.presentingViewController?.isBeingPresented ?? true {
            self.present(errorAlert, animated: true)
        }
        pullToRefresh.endRefreshing()
    }
    
    func addChannel(channel: ChannelModel) {
        guard let dataSource = dataSource else { return }
        var snapshot = dataSource.snapshot()
        snapshot.appendItems([channel], toSection: 0)
        guard let indexOfNewChannel = snapshot.indexOfItem(channel) else { return }
        dataSource.apply(snapshot)
        tableView.scrollToRow(at: IndexPath(item: indexOfNewChannel, section: 0), at: .bottom, animated: true)
    }
}
