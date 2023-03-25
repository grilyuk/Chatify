import UIKit

protocol ConversationViewProtocol: AnyObject {
    func showConversation()
    var historyChat: [MessageCellModel] { get set }
    var handler: (([MessageCellModel], String) -> Void)? { get set }
}

class ConversationViewController: UIViewController {
    
    //MARK: - UIConstants
    private enum UIConstants {
        static let borderWidth: CGFloat = 2
        static let textFieldHeight: CGFloat = 36
        static let avatarSize: CGFloat = 50
        static let imageProfileTopColor: UIColor = #colorLiteral(red: 0.9541506171, green: 0.5699337721, blue: 0.6460854411, alpha: 1)
        static let imageProfileBottomColor: UIColor = #colorLiteral(red: 0.6705197704, green: 0.6906016156, blue: 0.8105463435, alpha: 1)
    }
    
    //MARK: - Public
    var presenter: ConversationPresenterProtocol?
    var handler: (([MessageCellModel], String) -> Void)?
    var historyChat: [MessageCellModel] = []
    var titlesSections: [String] = []
    var userName: String = "Steve Jobs"
    weak var themeService: ThemeServiceProtocol?
    
    //MARK: - Private
// еще раз прошу прощения за форс...
    private lazy var dataSource = ConversationDataSource(tableView: tableView, themeService: themeService!)
    private var imageProfileBottomColor: UIColor?
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.register(IncomingConversationViewCell.self, forCellReuseIdentifier: IncomingConversationViewCell.identifier)
        table.register(OutgoingConversationViewCell.self, forCellReuseIdentifier: OutgoingConversationViewCell.identifier)
        table.delegate = self
        table.rowHeight = UITableView.automaticDimension
        table.separatorStyle = .none
        table.allowsSelection = false
        return table
    }()
    
    private lazy var textFieldView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = UIConstants.textFieldHeight/2
        view.layer.borderWidth = UIConstants.borderWidth
        view.layer.borderColor = UIColor.systemGray5.cgColor
        return view
    }()
    
    private lazy var textField: UITextField = {
        let field = UITextField()
        field.placeholder = "Type message"
        return field
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        let arrowImage = UIImage(systemName: "arrow.up.circle.fill")
        button.setImage(arrowImage, for: .normal)
        return button
    }()
    
    private lazy var customNavBar: UIView = {
        let navBar = UIView(frame: CGRect(x: 0, y: 0,
                                          width: view.frame.width,
                                          height: view.frame.height * (137/844)))
        let blur = UIBlurEffect(style: .regular)
        let blurEffectView = UIVisualEffectView(effect: blur)
        blurEffectView.frame = navBar.bounds
        blurEffectView.alpha = 0.2
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        navBar.addSubview(blurEffectView)
        navBar.backgroundColor = themeService?.currentTheme.backgroundColor
        return navBar
    }()
    
    private lazy var companionAvatar: UIView = {
        let view = UIView(frame: CGRect(origin: .zero, size: .init(width: UIConstants.avatarSize, height: UIConstants.avatarSize)))

        let gradient = CAGradientLayer()
        gradient.colors = [UIConstants.imageProfileTopColor.cgColor,
                           UIConstants.imageProfileBottomColor.cgColor]
        gradient.frame = view.bounds
        view.layer.addSublayer(gradient)
        view.layer.cornerRadius = UIConstants.avatarSize/2
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var initials: UILabel = {
        let label = UILabel()
        let initialFontSizeCalc = UIConstants.avatarSize * 0.45
        let descriptor = UIFont.systemFont(ofSize: initialFontSizeCalc, weight: .semibold).fontDescriptor.withDesign(.rounded)
        label.font = UIFont(descriptor: descriptor!, size: initialFontSizeCalc)
        label.textColor = .white
        let formatter = PersonNameComponentsFormatter()
        let components = formatter.personNameComponents(from: userName)
        formatter.style = .abbreviated
        label.text = formatter.string(from: components!)
        return label
    }()
    
    private lazy var companionName: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.text = userName
        label.textColor = themeService?.currentTheme.textColor
        return label
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        let chevron = UIImage(systemName: "chevron.left")
        button.setImage(chevron, for: .normal)
        button.addTarget(self, action: #selector(popToRoot), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Initializer
    init(themeService: ThemeServiceProtocol) {
        self.themeService = themeService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewReady()
        setDataSource()
        setTableView()
        setGesture()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showKeyboard),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(hideKeyboard),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.backgroundColor = themeService?.currentTheme.backgroundColor
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }

    //MARK: - Set DataSource
    private func setDataSource() {
        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"

        let groupedMessages = Dictionary(grouping: historyChat, by: { Calendar.current.startOfDay(for: $0.date) })
        let sortedDates = groupedMessages.keys.sorted()
        
        for date in sortedDates {
            var messages = groupedMessages[date] ?? []
            titlesSections.append(formatter.string(from: date))
            messages.sort { $0.date < $1.date }
            snapshot.appendSections([date])
            snapshot.appendItems(messages)
        }
        dataSource.apply(snapshot)
    }
    
    //MARK: - Methods
    private func setGesture() {
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc
    private func showKeyboard(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {return}

        let keyboardHeight = keyboardFrame.height
        let viewYMax = view.frame.maxY
        let safeAreaYMax = view.safeAreaLayoutGuide.layoutFrame.maxY
        let height = viewYMax - safeAreaYMax
        let offset = keyboardHeight - height
        let sections = tableView.numberOfSections
        let rowCount = tableView.numberOfRows(inSection: sections - 1)
        additionalSafeAreaInsets.bottom = offset
        tableView.scrollToRow(at: IndexPath(row: rowCount - 1, section: sections - 1), at: .bottom, animated: true)
        tableView.scrollsToTop = true
    }

    @objc
    private func hideKeyboard(_ notification: Notification) {
        additionalSafeAreaInsets.bottom = 0
    }
    
    @objc
    private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc
    private func popToRoot() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    //MARK: - Setup UI
    private func setTableView() {
        view.addSubview(tableView)
        view.addSubview(textFieldView)
        textFieldView.addSubview(textField)
        textFieldView.addSubview(sendButton)
        view.addSubview(customNavBar)
        customNavBar.addSubview(companionAvatar)
        companionAvatar.addSubview(initials)
        customNavBar.addSubview(companionName)
        customNavBar.addSubview(backButton)
        
        textFieldView.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        customNavBar.translatesAutoresizingMaskIntoConstraints = false
        companionAvatar.translatesAutoresizingMaskIntoConstraints = false
        initials.translatesAutoresizingMaskIntoConstraints = false
        companionName.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false
        
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
            textField.leadingAnchor.constraint(equalTo: textFieldView.leadingAnchor, constant: 10),
            textField.trailingAnchor.constraint(equalTo: textFieldView.trailingAnchor, constant: -10),
            
            sendButton.heightAnchor.constraint(equalTo: textField.heightAnchor),
            sendButton.centerYAnchor.constraint(equalTo: textField.centerYAnchor),
            sendButton.trailingAnchor.constraint(equalTo: textField.trailingAnchor),
            sendButton.widthAnchor.constraint(equalTo: textField.heightAnchor),
            
            customNavBar.topAnchor.constraint(equalTo: view.topAnchor),
            customNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavBar.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.16),
            
            companionAvatar.centerXAnchor.constraint(equalTo: customNavBar.centerXAnchor),
            companionAvatar.bottomAnchor.constraint(equalTo: customNavBar.bottomAnchor, constant: -30),
            companionAvatar.heightAnchor.constraint(equalToConstant: UIConstants.avatarSize),
            companionAvatar.widthAnchor.constraint(equalToConstant: UIConstants.avatarSize),
            
            initials.centerYAnchor.constraint(equalTo: companionAvatar.centerYAnchor),
            initials.centerXAnchor.constraint(equalTo: companionAvatar.centerXAnchor),
            
            companionName.centerXAnchor.constraint(equalTo: customNavBar.centerXAnchor),
            companionName.topAnchor.constraint(equalTo: companionAvatar.bottomAnchor, constant: 5),
            
            backButton.centerYAnchor.constraint(equalTo: customNavBar.centerYAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: customNavBar.leadingAnchor, constant: 18)
        ])
    }

}

//MARK: - ConversationViewController + UITableViewDelegate
extension ConversationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let title = UILabel()
        let blur = UIBlurEffect(style: .regular)
        let blurEffectView = UIVisualEffectView(effect: blur)
        blurEffectView.frame = CGRect(origin: .zero, size: CGSize(width: view.frame.width, height: tableView.estimatedSectionHeaderHeight))
        title.frame = blurEffectView.bounds
        blurEffectView.alpha = 0.8
        title.translatesAutoresizingMaskIntoConstraints = false
        blurEffectView.contentView.addSubview(title)
        NSLayoutConstraint.activate([
            title.centerYAnchor.constraint(equalTo: blurEffectView.centerYAnchor),
            title.centerXAnchor.constraint(equalTo: blurEffectView.centerXAnchor)
        ])
        title.text = titlesSections[section]
        title.font = .systemFont(ofSize: 12)
        title.textAlignment = .center
        title.textColor = themeService?.currentTheme.textColor
        blurEffectView.contentView.backgroundColor = themeService?.currentTheme.backgroundColor
        return blurEffectView
    }
}

//MARK: - ConversationViewController + ConversationViewProtocol
extension ConversationViewController: ConversationViewProtocol {
    func showConversation() {
        handler = { [weak self] history, name in
            self?.historyChat = history
            self?.userName = name
        }
        view.backgroundColor = themeService?.currentTheme.backgroundColor
    }
}
