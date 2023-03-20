import UIKit

protocol ProfileViewProtocol: AnyObject {
    func showProfile(profile: ProfileModel)
}

class ProfileViewController: UIViewController, UINavigationBarDelegate {
    
    //MARK: - Initializer
    init(themeService: ThemeServiceProtocol) {
        self.themeService = themeService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UIConstants
    private enum UIConstants {
        static let fontSize: CGFloat = 17
        static let largerFontSize: CGFloat = 22
        static let initialsFontSize: CGFloat = 68
        static let navBarToProfileImage: CGFloat = 32
        static let imageProfileSize: CGFloat = 150
        static let imageProfileToAddPhoto: CGFloat = 24
        static let addPhotoToNameLabel: CGFloat = 24
        static let nameLabelToInfoText: CGFloat = 10
        static let imageProfileTopColor: UIColor = UIColor(red: 241/255, green: 159/255, blue: 180/255, alpha: 1)
        static let imageProfileBottomColor: UIColor = UIColor(red: 238/255, green: 123/255, blue: 149/255, alpha: 1)
    }
    
    //MARK: - Public
    var profileImageView = UIImageView()
    var presenter: ProfilePresenterProtocol?
    weak var themeService: ThemeServiceProtocol?
    var convListPresenter: ConvListPresenterProtocol?
    
    //MARK: - Private
    private lazy var navigationBar = UINavigationBar()
    private lazy var navTitle = UINavigationItem()
    private lazy var navSaveProfile = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"))
    private lazy var activity = UIActivityIndicatorView.init(style: .medium)
    private lazy var placeholderImage = UIImage(systemName: "person.fill")?.scalePreservingAspectRatio(targetSize: CGSizeMake(100, 100)).withTintColor(.gray)
    private lazy var dispatch = GCDDataManager()
    private lazy var activityIndicator = UIActivityIndicatorView(style: .medium)
    
    private lazy var fullNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: UIConstants.largerFontSize, weight: .bold)
        return label
    }()
    
    private lazy var addPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add photo", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: UIConstants.fontSize)
        return button
    }()
    
    private lazy var bioText: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textAlignment = .center
        textView.font = UIFont.systemFont(ofSize: UIConstants.fontSize, weight: .regular)
        textView.isScrollEnabled = false
        return textView
    }()
    
    private lazy var editableNameSection: UITextField = {
        let textField = UITextField()
        textField.isHidden = true
        return textField
    }()
    
    private lazy var editableBioSection: UITextField = {
        let textField = UITextField()
        textField.isHidden = true
        return textField
    }()
    
    private lazy var nameCell: UITableViewCell = {
        let nameCell = UITableViewCell()
        var config = UIListContentConfiguration.cell()
        config.text = "Name"
        nameCell.separatorInset = .init(top: 20, left: 20, bottom: 0, right: 0)
        nameCell.contentConfiguration = config
        nameCell.isHidden = true
        nameCell.backgroundColor = .white
        return nameCell
    }()
    
    private lazy var bioCell: UITableViewCell = {
        let bioCell = UITableViewCell()
        var config = UIListContentConfiguration.cell()
        config.text = "Bio"
        bioCell.contentConfiguration = config
        bioCell.isHidden = true
        bioCell.backgroundColor = .white
        return bioCell
    }()
    
    private lazy var userAvatar: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
        let gradient = CAGradientLayer()
        gradient.colors = [UIConstants.imageProfileTopColor.cgColor,
                           UIConstants.imageProfileBottomColor.cgColor]
        gradient.frame = imageView.bounds
        imageView.layer.addSublayer(gradient)
        imageView.layer.cornerRadius = 50
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var editButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitle("Edit", for: .normal)
        return button
    }()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        editButton.addTarget(self, action: #selector(editProfileTapped), for: .touchUpInside)
        addPhotoButton.addTarget(self, action: #selector(addPhototapped), for: .touchUpInside)
        presenter?.viewReady()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        view.backgroundColor = themeService?.currentTheme.backgroundColor
        bioText.textColor = themeService?.currentTheme.textColor
        bioText.backgroundColor = themeService?.currentTheme.backgroundColor
        fullNameLabel.textColor = themeService?.currentTheme.textColor
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: themeService?.currentTheme.textColor ?? .gray]
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if fullNameLabel.text == "No name" {
            profileImageView.image = placeholderImage
            profileImageView.backgroundColor = .systemGray4
            profileImageView.contentMode = .center
        } else if profileImageView.image == placeholderImage && fullNameLabel.text == "No name" {
            profileImageView = userAvatar
        } else {
            profileImageView.contentMode = .scaleAspectFit
        }
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.clipsToBounds = true
    }
    
    //MARK: - Setup UI
    private func setupUI() {
        setNavBar()
        setNavBarButtons()
        setConstraints()
        setGesture()
    }
    
    //MARK: - Methods
    private func setGesture() {
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setNavBarButtons() {
        let navCloseButton = UIBarButtonItem(title: "Close",
                                             style: .plain,
                                             target: self,
                                             action: #selector(closeProfileTapped))
        let navEditProfile = UIBarButtonItem(customView: editButton)
        navTitle.leftBarButtonItem = navCloseButton
        navTitle.rightBarButtonItem = navEditProfile
    }
    
    private func setNavBar() {
        navTitle.title = "My Profile"
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: UIConstants.fontSize, weight: .bold)]
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: themeService?.currentTheme.textColor ?? .gray]
        UINavigationBar.appearance().standardAppearance = appearance
        navTitle.leftBarButtonItem?.setTitleTextAttributes([ NSAttributedString.Key.font : UIFont.systemFont(ofSize: UIConstants.fontSize, weight: .regular)], for: .normal)
        navTitle.rightBarButtonItem?.setTitleTextAttributes([ NSAttributedString.Key.font : UIFont.systemFont(ofSize: UIConstants.fontSize, weight: .regular)], for: .normal)
        navigationBar.setItems([navTitle], animated: false)
    }
    
    private func editableMode() {
        fullNameLabel.isHidden = true
        bioText.isHidden = true
        editableNameSection.isHidden = false
        editableBioSection.isHidden = false
        navTitle.title = "Edit profile"
        nameCell.isHidden = false
        bioCell.isHidden = false
        editableNameSection.becomeFirstResponder()
        
        let saveGCD = UIAction(title: "Save GCD") { _ in
            guard let nameText = self.editableNameSection.text,
                  let statusText = self.editableBioSection.text else { return }
            self.editableNameSection.isEnabled = false
            self.editableBioSection.isEnabled = false
            self.activityIndicator.startAnimating()
            self.navTitle.rightBarButtonItem = UIBarButtonItem(customView: self.activityIndicator)
            self.dispatch.writeData(name: nameText, statusText: statusText, profileImage: nil) { result in
                switch result {
                case .success(true):
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Success!", message: "Data saved", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default)
                        alert.addAction(okAction)
                        self.fullNameLabel.text = nameText
                        self.bioText.text = statusText
                        self.activityIndicator.stopAnimating()
                        self.setNavBarButtons()
                        self.setEditFinished()
                        self.present(alert, animated: true)
                    }
                case .success(false):
                    DispatchQueue.main.async {
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        
        let saveOpeartion = UIAction(title: "Save Operations") { _ in
            //Opearations
            self.setNavBarButtons()
            self.setEditFinished()
        }
        navSaveProfile.menu = UIMenu(children: [saveGCD, saveOpeartion])
        navTitle.rightBarButtonItem = navSaveProfile
    }
    
    private func setEditFinished() {
        nameCell.isHidden = true
        bioCell.isHidden = true
        editableNameSection.isHidden = true
        editableBioSection.isHidden = true
        editableNameSection.isEnabled = true
        editableBioSection.isEnabled = true
        fullNameLabel.isHidden = false
        bioText.isHidden = false
        navTitle.title = "My Profile"
        navTitle.rightBarButtonItems?.removeAll()
        let navEditProfile = UIBarButtonItem(customView: editButton)
        navTitle.rightBarButtonItem = navEditProfile
    }
    
    @objc
    private func editProfileTapped() {
        editableMode()
    }
    
    @objc
    private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc
    private func closeProfileTapped() {
        if editableNameSection.isHidden == false {
            setEditFinished()
        } else {
            self.dismiss(animated: true)
        }
    }
    
    @objc
    private func addPhototapped() {
        editableMode()
        let alert = AlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        present(alert, animated: true) {
            alert.vc = self
        }
    }
    
    private func setConstraints() {
        view.addSubviews(navigationBar, profileImageView, addPhotoButton, fullNameLabel, bioText, nameCell,bioCell)
        nameCell.addSubview(editableNameSection)
        bioCell.addSubview(editableBioSection)
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        addPhotoButton.translatesAutoresizingMaskIntoConstraints = false
        fullNameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameCell.translatesAutoresizingMaskIntoConstraints = false
        bioCell.translatesAutoresizingMaskIntoConstraints = false
        editableNameSection.translatesAutoresizingMaskIntoConstraints = false
        editableBioSection.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.widthAnchor.constraint(equalToConstant: view.frame.width),
            
            profileImageView.widthAnchor.constraint(equalToConstant: UIConstants.imageProfileSize),
            profileImageView.heightAnchor.constraint(equalToConstant: UIConstants.imageProfileSize),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: UIConstants.navBarToProfileImage),
            
            addPhotoButton.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: UIConstants.imageProfileToAddPhoto),
            addPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            fullNameLabel.topAnchor.constraint(equalTo: addPhotoButton.bottomAnchor, constant: UIConstants.addPhotoToNameLabel),
            fullNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            bioText.topAnchor.constraint(equalTo: fullNameLabel.bottomAnchor, constant: UIConstants.nameLabelToInfoText),
            bioText.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            nameCell.widthAnchor.constraint(equalTo: view.widthAnchor),
            nameCell.topAnchor.constraint(equalTo: addPhotoButton.bottomAnchor, constant: 24),
            nameCell.heightAnchor.constraint(equalToConstant: 44),
            
            bioCell.widthAnchor.constraint(equalTo: view.widthAnchor),
            bioCell.topAnchor.constraint(equalTo: nameCell.bottomAnchor),
            bioCell.heightAnchor.constraint(equalToConstant: 44),
            
            editableNameSection.centerYAnchor.constraint(equalTo: nameCell.centerYAnchor),
            editableNameSection.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 120),
            editableNameSection.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            editableBioSection.centerYAnchor.constraint(equalTo: bioCell.centerYAnchor),
            editableBioSection.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 120),
            editableBioSection.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

//MARK: - ProfileViewController + ProfileViewProtocol
extension ProfileViewController: ProfileViewProtocol {
    func showProfile(profile: ProfileModel) {
        self.fullNameLabel.text = {
            if profile.fullName == nil || profile.fullName == "" {
                return "No name"
            } else {
                return profile.fullName
            }
        }()
        self.bioText.text = {
            if profile.statusText == nil || profile.statusText == "" {
                return "No bio specified"
            } else {
                return profile.statusText
            }
        }()
        if profile.profileImageData == nil {
            self.profileImageView.image = placeholderImage
        } else {
            guard let imageData = profile.profileImageData else { return }
            self.profileImageView.image = UIImage(data: imageData)
        }
    }
}
