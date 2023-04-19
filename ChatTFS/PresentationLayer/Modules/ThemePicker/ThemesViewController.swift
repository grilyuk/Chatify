import UIKit

class ThemesViewController: UIViewController {
    
    // MARK: - UIConstants
    
    enum UIConstants {
        static let cornerRadius: CGFloat = 16
        static let borderOnExample: CGFloat = 1.5
        static let fontSize: CGFloat = 15
        static let bubbleToTopSafe: CGFloat = 26
        static let bubbleWidth: CGFloat = -32
        static let edgeToExample: CGFloat = 30
        static let labelSpace: CGFloat = 20
    }
    
    // MARK: - Initialization
    
    init(themeService: ThemeServiceProtocol) {
        self.themeService = themeService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private properties
    
    private var themeService: ThemeServiceProtocol?
    private var themeHandler: ((Theme) -> Void)?
    
    private lazy var bubble: UIView = {
        let view = UIView()
        view.layer.cornerRadius = UIConstants.cornerRadius
        view.clipsToBounds = true
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private lazy var lightExample: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "lightTheme")
        view.contentMode = .scaleAspectFit
        view.layer.cornerRadius = UIConstants.cornerRadius
        view.clipsToBounds = true
        view.backgroundColor = .white
        view.layer.borderWidth = UIConstants.borderOnExample
        view.layer.borderColor = UIColor.lightGray.cgColor
        return view
    }()
    
    private lazy var darkExample: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "darkTheme")
        view.contentMode = .scaleAspectFit
        view.layer.cornerRadius = UIConstants.cornerRadius
        view.clipsToBounds = true
        view.backgroundColor = .black
        view.layer.borderWidth = UIConstants.borderOnExample
        view.layer.borderColor = UIColor.systemGray5.cgColor
        return view
    }()
    
    private lazy var dayLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UIConstants.fontSize)
        label.text = "Day"
        return label
    }()
    
    private lazy var nightLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UIConstants.fontSize)
        label.text = "Night"
        return label
    }()
    
    private lazy var dayTickButton: UIButton = {
        let checkmarkButton = UIButton(type: .custom)
        checkmarkButton.setImage(UIImage(systemName: "circle"), for: .normal)
        checkmarkButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected)
        checkmarkButton.addTarget(self, action: #selector(tappedDayButton), for: .touchUpInside)
        return checkmarkButton
    }()
    
    private lazy var nightTickButton: UIButton = {
        let checkmarkButton = UIButton(type: .custom)
        checkmarkButton.setImage(UIImage(systemName: "circle"), for: .normal)
        checkmarkButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected)
        checkmarkButton.addTarget(self, action: #selector(tappedNightButton), for: .touchUpInside)
        return checkmarkButton
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        themeHandler = { [weak self] theme in
            self?.themeService?.currentTheme = theme
        }
        guard let currentTheme = themeService?.currentTheme else { return }
        fetchTheme(currentTheme: currentTheme)
        setNavigationBar()
        setupConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.bubble.backgroundColor = themeService?.currentTheme.themeBubble
        self.dayLabel.textColor = themeService?.currentTheme.textColor
        self.nightLabel.textColor = themeService?.currentTheme.textColor
        view.backgroundColor = themeService?.currentTheme.backgroundColor
    }
    
    // MARK: - Private methods
    
    private func fetchTheme(currentTheme: Theme) {
        switch currentTheme {
        case .light:
            dayTickButton.isSelected = true
            nightTickButton.imageView?.tintColor = .gray
        case .dark:
            nightTickButton.isSelected = true
            dayTickButton.imageView?.tintColor = .gray
        }
    }
    
    private func setNavigationBar() {
        self.title = "Settings"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    @objc
    private func tappedDayButton(_ sender: UIButton) {
        let lightTheme = Theme.light
        themeHandler?(lightTheme)
        sender.isSelected = true
        sender.imageView?.tintColor = .systemBlue
        nightTickButton.isSelected = false
        nightTickButton.imageView?.tintColor = .gray
        let navBarStyle = UINavigationBarAppearance()
        navBarStyle.backgroundColor = lightTheme.backgroundColor
        navBarStyle.titleTextAttributes = [ NSAttributedString.Key.foregroundColor: lightTheme.textColor ]
        navBarStyle.largeTitleTextAttributes = [ NSAttributedString.Key.foregroundColor: lightTheme.textColor ]
        changeNavBar(appearance: navBarStyle)
        UIApplication.shared.windows[0].overrideUserInterfaceStyle = .light
        tabBarController?.tabBar.barTintColor = lightTheme.backgroundColor
        navigationController?.navigationBar.backgroundColor = lightTheme.backgroundColor
    }
    
    @objc
    private func tappedNightButton(_ sender: UIButton) {
        let darkTheme = Theme.dark
        themeHandler?(darkTheme)
        sender.isSelected = true
        sender.imageView?.tintColor = .systemBlue
        dayTickButton.isSelected = false
        dayTickButton.imageView?.tintColor = .gray
        let navBarStyle = UINavigationBarAppearance()
        navBarStyle.backgroundColor = darkTheme.backgroundColor
        navBarStyle.titleTextAttributes = [ NSAttributedString.Key.foregroundColor: darkTheme.textColor ]
        navBarStyle.largeTitleTextAttributes = [ NSAttributedString.Key.foregroundColor: darkTheme.textColor ]
        changeNavBar(appearance: navBarStyle)
        UIApplication.shared.windows[0].overrideUserInterfaceStyle = .dark
        tabBarController?.tabBar.barTintColor = darkTheme.backgroundColor
        navigationController?.navigationBar.backgroundColor = darkTheme.backgroundColor
    }
    
    private func changeNavBar(appearance: UINavigationBarAppearance) {
        navigationController?.navigationItem.scrollEdgeAppearance = appearance
        navigationController?.navigationItem.standardAppearance = appearance
        navigationController?.navigationItem.compactAppearance = appearance
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    private func setupConstraints() {
        view.addSubview(bubble)
        bubble.addSubviews(lightExample, darkExample, dayTickButton, nightTickButton, dayLabel, nightLabel)
        bubble.translatesAutoresizingMaskIntoConstraints = false
        lightExample.translatesAutoresizingMaskIntoConstraints = false
        darkExample.translatesAutoresizingMaskIntoConstraints = false
        dayTickButton.translatesAutoresizingMaskIntoConstraints = false
        nightTickButton.translatesAutoresizingMaskIntoConstraints = false
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        nightLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            bubble.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: UIConstants.bubbleToTopSafe),
            bubble.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bubble.widthAnchor.constraint(equalTo: view.widthAnchor, constant: UIConstants.bubbleWidth),
            bubble.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 2 / 7),
            
            lightExample.widthAnchor.constraint(equalTo: bubble.widthAnchor, multiplier: 1 / 3),
            lightExample.heightAnchor.constraint(equalTo: bubble.heightAnchor, multiplier: 1 / 3),
            lightExample.leadingAnchor.constraint(equalTo: bubble.leadingAnchor, constant: UIConstants.edgeToExample),
            lightExample.topAnchor.constraint(equalTo: bubble.topAnchor, constant: UIConstants.edgeToExample),
            
            darkExample.widthAnchor.constraint(equalTo: bubble.widthAnchor, multiplier: 1 / 3),
            darkExample.heightAnchor.constraint(equalTo: bubble.heightAnchor, multiplier: 1 / 3),
            darkExample.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -UIConstants.edgeToExample),
            darkExample.topAnchor.constraint(equalTo: bubble.topAnchor, constant: UIConstants.edgeToExample),
            
            dayLabel.centerXAnchor.constraint(equalTo: lightExample.centerXAnchor),
            dayLabel.topAnchor.constraint(equalTo: lightExample.bottomAnchor, constant: UIConstants.labelSpace),
            
            nightLabel.centerXAnchor.constraint(equalTo: darkExample.centerXAnchor),
            nightLabel.topAnchor.constraint(equalTo: darkExample.bottomAnchor, constant: UIConstants.labelSpace),
            
            dayTickButton.centerXAnchor.constraint(equalTo: lightExample.centerXAnchor),
            dayTickButton.widthAnchor.constraint(equalTo: lightExample.widthAnchor),
            dayTickButton.heightAnchor.constraint(equalTo: view.heightAnchor),
            dayTickButton.centerYAnchor.constraint(equalTo: bubble.bottomAnchor, constant: -UIConstants.edgeToExample),
            
            nightTickButton.centerXAnchor.constraint(equalTo: darkExample.centerXAnchor),
            nightTickButton.widthAnchor.constraint(equalTo: darkExample.widthAnchor),
            nightTickButton.heightAnchor.constraint(equalTo: view.heightAnchor),
            nightTickButton.centerYAnchor.constraint(equalTo: bubble.bottomAnchor, constant: -UIConstants.edgeToExample)
        ])
    }
}
