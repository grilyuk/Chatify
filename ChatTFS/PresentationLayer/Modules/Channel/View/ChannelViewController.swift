import UIKit

protocol ChannelViewProtocol: AnyObject {
    func showChannel(channel: ChannelModel)
    func addMessage(message: MessageModel)
    var messages: [MessageModel] { get set }
    var titlesSections: [String] { get set }
    func setImageMessage(link: String)
    func updateImage(image: UIImage, id: UUID)
}

class ChannelViewController: UIViewController {
    
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
        static let borderWidth: CGFloat = 2
        static let textFieldHeight: CGFloat = 40
        static let avatarSize: CGFloat = 50
    }
    
    // MARK: - Public
    
    var presenter: ChannelPresenterProtocol?
    var messages: [MessageModel] = []
    var titlesSections: [String] = []
    var themeService: ThemeServiceProtocol
    
    // MARK: - Private

    private lazy var dataSource = ChannelDataSource(tableView: tableView, themeService: themeService, view: self)
    private lazy var logoEmitterAnimation = EmitterAnimation(layer: view.layer)
    
    private var tableView: UITableView = {
        let table = UITableView()
        table.register(IncomingChannelViewCell.self, forCellReuseIdentifier: IncomingChannelViewCell.identifier)
        table.register(OutgoingChannelViewCell.self, forCellReuseIdentifier: OutgoingChannelViewCell.identifier)
        table.register(SameIncomingChannelViewCell.self, forCellReuseIdentifier: SameIncomingChannelViewCell.identifier)
        table.separatorStyle = .none
        table.allowsSelection = false
        table.scrollsToTop = true
        table.rowHeight = UITableView.automaticDimension
        if #available(iOS 15.0, *) {
            table.sectionHeaderTopPadding = 0
        }
        return table
    }()
    
    private lazy var textFieldView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = UIConstants.textFieldHeight / 2
        view.clipsToBounds = true
        view.layer.borderWidth = UIConstants.borderWidth
        view.layer.borderColor = UIColor.systemGray5.cgColor
        view.backgroundColor = themeService.currentTheme.themeBubble
        return view
    }()
    
    private lazy var textField: UITextField = {
        let field = UITextField()
        field.placeholder = "Type message"
        field.tintColor = themeService.currentTheme.incomingTextColor
        field.backgroundColor = themeService.currentTheme.themeBubble
        return field
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        let arrowImage = UIImage(systemName: "arrow.up.circle.fill")
        let image = arrowImage?.scalePreservingAspectRatio(targetSize: CGSize(width: UIConstants.textFieldHeight * 0.7,
                                                                              height: UIConstants.textFieldHeight * 0.7))
        button.setImage(image, for: .normal)
        return button
    }()
    
    private lazy var customNavBar: UIView = {
        let navBar = UIView(frame: CGRect(x: 0, y: 0,
                                          width: view.frame.width,
                                          height: view.frame.height * (137 / 844)))
        let blur = UIBlurEffect(style: .regular)
        let blurEffectView = UIVisualEffectView(effect: blur)
        blurEffectView.frame = navBar.bounds
        blurEffectView.alpha = 0.2
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        navBar.addSubview(blurEffectView)
        navBar.backgroundColor = themeService.currentTheme.backgroundColor
        return navBar
    }()
    
    private lazy var channelLogo: UIImageView = {
        let view = UIImageView(frame: CGRect(origin: .zero, size: .init(width: UIConstants.avatarSize, height: UIConstants.avatarSize)))
        view.layer.cornerRadius = UIConstants.avatarSize / 2
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    private lazy var channelName: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = themeService.currentTheme.textColor
        return label
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        let chevron = UIImage(systemName: "chevron.left")
        button.setImage(chevron, for: .normal)
        button.addTarget(self, action: #selector(popToRoot), for: .touchUpInside)
        return button
    }()
    
    private lazy var choosePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        let photoImage = UIImage(systemName: "photo.circle")
        let image = photoImage?.scalePreservingAspectRatio(targetSize: CGSize(width: UIConstants.textFieldHeight * 0.75,
                                                                              height: UIConstants.textFieldHeight * 0.75))
        button.setImage(image, for: .normal)
        return button
    }()
    
    private lazy var activityIndicator = UIActivityIndicatorView(style: .medium)
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = dataSource
        tableView.panGestureRecognizer.addTarget(self, action: #selector(handlePanTouch(sender: )))
        presenter?.viewReady()
        dataSource.defaultRowAnimation = .fade
        setTableView()
        activityIndicator.startAnimating()
        sendButton.addTarget(self, action: #selector(checkMessage), for: .touchUpInside)
        choosePhotoButton.addTarget(self, action: #selector(pickPhoto), for: .touchUpInside)
        addKeyboardObserver()
        hideKeyboardWhenTappedOutside()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.backgroundColor = themeService.currentTheme.backgroundColor
        customNavBar.backgroundColor = themeService.currentTheme.themeBubble
        presenter?.subscribeToSSE()
        view.backgroundColor = themeService.currentTheme.backgroundColor
        navigationController?.navigationBar.isHidden = true
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
        navigationController?.navigationBar.isHidden = false
        presenter?.unsubscribeFromSSE()
    }
    
    // MARK: - Methods
    
    func scrollToLastRow() {
        if !messages.isEmpty {
            view.layoutIfNeeded()
            let lastSectionNumber = tableView.numberOfSections - 1
            let lastRowInSection = tableView.numberOfRows(inSection: lastSectionNumber) - 1
            tableView.scrollToRow(at: IndexPath(item: lastRowInSection, section: lastSectionNumber ), at: .none, animated: true)
        }
    }
    
    private func sendMessage() {
        presenter?.createMessage(messageText: textField.text)
        textField.text = ""
    }
    
    @objc
    private func checkMessage() {
        !(textField.text == nil || textField.text == "") ? sendMessage() : ()
    }
    
    @objc
    private func popToRoot() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc
    private func pickPhoto() {
        view.endEditing(true)
        guard let navigationController = self.navigationController else {
            return
        }
        presenter?.showNetworkImages(navigationController: navigationController,
                                     vc: self)
    }
    
    @objc
    private func handlePanTouch(sender: UIPanGestureRecognizer) {
        logoEmitterAnimation.setupPanGesture(sender: sender, view: self.view)
    }
    
    // MARK: - Setup UI
    
    private func setTableView() {
        view.addSubview(tableView)
        view.addSubview(textFieldView)
        view.addSubview(activityIndicator)
        textFieldView.addSubview(textField)
        textFieldView.addSubview(sendButton)
        textFieldView.addSubview(choosePhotoButton)
        view.addSubview(customNavBar)
        customNavBar.addSubview(channelLogo)
        customNavBar.addSubview(channelName)
        customNavBar.addSubview(backButton)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        textFieldView.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        customNavBar.translatesAutoresizingMaskIntoConstraints = false
        channelLogo.translatesAutoresizingMaskIntoConstraints = false
        channelName.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        choosePhotoButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.bottomAnchor.constraint(equalTo: textFieldView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: customNavBar.bottomAnchor),
            
            textFieldView.heightAnchor.constraint(equalToConstant: UIConstants.textFieldHeight),
            textFieldView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            textFieldView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            textFieldView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            textField.bottomAnchor.constraint(equalTo: textFieldView.bottomAnchor, constant: -5),
            textField.topAnchor.constraint(equalTo: textFieldView.topAnchor, constant: 5),
            textField.leadingAnchor.constraint(equalTo: choosePhotoButton.trailingAnchor),
            textField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -5),
            
            sendButton.heightAnchor.constraint(equalTo: textFieldView.heightAnchor),
            sendButton.centerYAnchor.constraint(equalTo: textField.centerYAnchor),
            sendButton.trailingAnchor.constraint(equalTo: textFieldView.trailingAnchor),
            sendButton.widthAnchor.constraint(equalTo: textFieldView.heightAnchor),
            
            choosePhotoButton.centerYAnchor.constraint(equalTo: textField.centerYAnchor),
            choosePhotoButton.heightAnchor.constraint(equalTo: textFieldView.heightAnchor),
            choosePhotoButton.widthAnchor.constraint(equalTo: textFieldView.heightAnchor),
            choosePhotoButton.leadingAnchor.constraint(equalTo: textFieldView.leadingAnchor),
            
            customNavBar.topAnchor.constraint(equalTo: view.topAnchor),
            customNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavBar.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.16),
            
            channelLogo.centerXAnchor.constraint(equalTo: customNavBar.centerXAnchor),
            channelLogo.bottomAnchor.constraint(equalTo: customNavBar.bottomAnchor, constant: -30),
            channelLogo.heightAnchor.constraint(equalToConstant: UIConstants.avatarSize),
            channelLogo.widthAnchor.constraint(equalToConstant: UIConstants.avatarSize),
            
            channelName.centerXAnchor.constraint(equalTo: customNavBar.centerXAnchor),
            channelName.topAnchor.constraint(equalTo: channelLogo.bottomAnchor, constant: 5),
            
            backButton.centerYAnchor.constraint(equalTo: customNavBar.centerYAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: customNavBar.leadingAnchor, constant: 18),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

// MARK: - ChannelViewController + UITableViewDelegate

extension ChannelViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let title = UILabel()
        let blur = UIBlurEffect(style: .regular)
        let blurEffectView = UIVisualEffectView(effect: blur)
        blurEffectView.frame = CGRect(origin: .zero, size: CGSize(width: view.frame.width, height: tableView.estimatedSectionHeaderHeight))
        blurEffectView.layer.cornerRadius = blurEffectView.frame.height / 2
        title.frame = blurEffectView.bounds
        blurEffectView.alpha = 0.6
        title.translatesAutoresizingMaskIntoConstraints = false
        blurEffectView.contentView.addSubview(title)
        NSLayoutConstraint.activate([
            title.centerYAnchor.constraint(equalTo: blurEffectView.centerYAnchor),
            title.centerXAnchor.constraint(equalTo: blurEffectView.centerXAnchor)
        ])
        title.text = titlesSections[section]
        title.font = .systemFont(ofSize: 12)
        title.textAlignment = .center
        title.textColor = themeService.currentTheme.textColor
        blurEffectView.layoutIfNeeded()
        return blurEffectView
    }
}

// MARK: - ChannelViewController + ChannelViewProtocol

extension ChannelViewController: ChannelViewProtocol {
    func showChannel(channel: ChannelModel) {
        dataSource.setupSnapshot()
        channelName.text = channel.name
        channelLogo.image = channel.channelImage
        activityIndicator.stopAnimating()
    }
    
    func addMessage(message: MessageModel) {
        messages.append(message)
        
        DispatchQueue.main.async { [weak self] in
            guard let self else {
                return
            }
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"
            self.titlesSections.append(formatter.string(from: message.date))
            self.dataSource.addMessage(message: message)
            self.scrollToLastRow()
        }
    }
    
    func setImageMessage(link: String) {
        textField.text = link
    }
    
    func updateImage(image: UIImage, id: UUID) {
        guard let index = messages.firstIndex(where: { $0.uuid == id }) else {
            return
        }
        messages[index].image = image
        dataSource.updateImage(id: id)
    }
}
