import UIKit
import Combine

protocol ChannelsListViewProtocol: AnyObject {
    var channels: [ChannelModel] { get set }
    func showChannelsList()
    func showAlert()
    func addChannel(channel: ChannelModel)
    func updateChannel(channel: ChannelModel)
    func deleteChannel(channel: ChannelModel)
}

class ChannelsListViewController: UIViewController {
    
    typealias DataSource = UITableViewDiffableDataSource<Int, UUID>
    
    // MARK: - Initialization
    
    init(themeService: ThemeServiceProtocol) {
        self.themeService = themeService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIConstants
    
    enum UIConstants {
        static let rowHeight: CGFloat = 76
        static let sectionHeight: CGFloat = 44
        static let imageSize: CGSize = CGSize(width: 44, height: 44)
    }
    
    // MARK: - Public properties
    
    var presenter: ChannelsListPresenterProtocol?
    var channels: [ChannelModel] = []
    lazy var dataSource = ChannelsListDataSource(tableView: tableView, themeService: themeService, view: self)
    
    // MARK: - Private properties
    
    private var themeService: ThemeServiceProtocol
    private lazy var activityIndicator = UIActivityIndicatorView(style: .medium)
    private lazy var pullToRefresh = UIRefreshControl()
    private lazy var logoEmitterAnimation = EmitterAnimation()
    
    private var tableView: UITableView = {
        let table = UITableView()
        table.register(ChannelListCell.self, forCellReuseIdentifier: ChannelListCell.identifier)
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        if #available(iOS 15.0, *) {
            table.sectionHeaderTopPadding = 0
        }
        return table
    }()
    
    private lazy var errorAlert: UIAlertController = {
        let alert = UIAlertController(title: "Ошибка", message: "Что-то пошло не так", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let retryAction = UIAlertAction(title: "Retry", style: .default) { _ in
            self.presenter?.viewReady()
        }
        alert.addAction(cancelAction)
        alert.addAction(retryAction)
        return alert
    }()
    
    private lazy var addChanelAlert: UIAlertController = {
        let alert = UIAlertController(title: "New channel", message: nil, preferredStyle: .alert)
        alert.addTextField()
        alert.textFields?.first?.placeholder = "Channel Name"
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancel)
        return alert
    }()
    
    private lazy var createChannel: UIAlertAction = {
        let alert = UIAlertAction(title: "Create", style: .default) { [weak addChanelAlert, weak self] _ in
            
            guard let textField = addChanelAlert?.textFields?.first
            else {
                return
            }
            self?.checkTextField(textField: textField)
        }
        return alert
    }()
    
    private lazy var emptyErrorAlert: UIAlertController = {
        let alert = UIAlertController(title: "Channel name empty!",
                                      message: "Имя канала не может быть пустым. \nВведите имя канала.",
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: "Retry", style: .cancel) { [weak self] _ in
            self?.showCreateChannelAC()
        }
        alert.addAction(action)
        return alert
    }()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.panGestureRecognizer.addTarget(self, action: #selector(handlePanTouch(sender: )))
//        let panGes = UIPanGestureRecognizer(target: self, action: #selector(handlePanTouch(sender: )))
//        panGes.cancelsTouchesInView = false
//        tableView.panGestureRecognizer.cancelsTouchesInView = false
//        view.addGestureRecognizer(panGes)
        tableView.delegate = self
        tableView.addSubview(pullToRefresh)
        addChanelAlert.addAction(createChannel)
        presenter?.viewReady()
        dataSource.defaultRowAnimation = .fade
        setupTableViewConstraints()
        pullToRefresh.addTarget(self, action: #selector(updateChannelList), for: .valueChanged)
        activityIndicator.startAnimating()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = themeService.currentTheme.backgroundColor
        tableView.backgroundColor = themeService.currentTheme.backgroundColor
        dataSource.updateColorCells(channels: channels)
        presenter?.subscribeToSSE()
        setupNavigationBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter?.unsubscribeFromSSE()
    }
    
    // MARK: - Private methods
    
    private func setupNavigationBar() {
        navigationItem.title = "Channels"
        let addChannelButton = UIBarButtonItem(title: "Add Channel", style: .plain, target: self, action: #selector(addChannelTapped))
        navigationItem.rightBarButtonItem = addChannelButton
        navigationController?.navigationBar.prefersLargeTitles = true
        tabBarController?.tabBar.isHidden = false
        
        switch themeService.currentTheme {
        case .light: changeNavigationBar(theme: .light)
        case .dark: changeNavigationBar(theme: .dark)
        }
    }
    
    private func changeNavigationBar(theme: Theme) {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = theme.backgroundColor
        appearance.titleTextAttributes = [ NSAttributedString.Key.foregroundColor: theme.textColor]
        appearance.largeTitleTextAttributes = [ NSAttributedString.Key.foregroundColor: theme.textColor ]
        navigationController?.navigationItem.scrollEdgeAppearance = appearance
        navigationController?.navigationItem.standardAppearance = appearance
        navigationController?.navigationItem.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
    }
    
    private func showCreateChannelAC() {
        present(addChanelAlert, animated: true)
    }
    
    private func checkTextField(textField: UITextField) {
        guard
            let textFieldIsEmpty = textField.text?.isEmpty,
            let textCheck = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        else {
            return
        }
        
        if textFieldIsEmpty || textCheck == "" {
            present(emptyErrorAlert, animated: true)
        } else {
            guard let channelName = textField.text
            else {
                return
            }
            presenter?.createChannel(name: channelName)
        }
    }
    
    private func setupTableViewConstraints() {
        view.addSubviews(tableView)
        tableView.addSubview(activityIndicator)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: tableView.centerYAnchor)
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
    
    @objc
    private func handlePanTouch(sender: UIPanGestureRecognizer) {
        logoEmitterAnimation.setupGesture(sender: sender, view: self.view)
    }
}

// MARK: - ChannelsListViewController + ChannelsListViewProtocol

extension ChannelsListViewController: ChannelsListViewProtocol {
    
    func showChannelsList() {
        dataSource.applySnapshot(channels: channels)
        pullToRefresh.endRefreshing()
        activityIndicator.stopAnimating()
    }
    
    func showAlert() {
        if errorAlert.presentingViewController?.isBeingPresented ?? true {
            present(errorAlert, animated: true)
        }
        pullToRefresh.endRefreshing()
    }
    
    func addChannel(channel: ChannelModel) {
        channels.append(channel)
        dataSource.addChannel(channel: channel)
    }
    
    func updateChannel(channel: ChannelModel) {
        dataSource.updateCell(channel: channel)
    }
    
    func deleteChannel(channel: ChannelModel) {
        guard let index = channels.firstIndex(of: channel)
        else {
            return
        }
        dataSource.deleteChannel(channel: channel)
        channels.remove(at: index)
    }
}
