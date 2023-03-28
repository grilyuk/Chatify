import UIKit
import Combine

protocol ProfileViewProtocol: AnyObject {
    func showProfile()
}

class ProfileViewController: UIViewController {
    
    //MARK: - Initializer
    init(themeService: ThemeServiceProtocol, profilePublisher: AnyPublisher<Data, Error>) {
        self.themeService = themeService
        self.profilePublisher = profilePublisher
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

    //MARK: - Private
    private enum State {
        case loading
        case profile(ProfileModel)
    }
    
    private var state: State = .loading {
        didSet {
            switch state {
            case .loading: print("")
            case .profile(let profile):
                self.nameLabel.text = profile.fullName
                self.bioText.text = profile.statusText
                if profile.profileImageData == nil {
                    profileImageView.image = placeholderImage
                } else {
                    guard let imageData = profile.profileImageData else { return }
                    profileImageView.image = UIImage(data: imageData)
                }
            }
        }
    }
    
    private var profilePublisher: AnyPublisher<Data, Error>
    private var profileRequest: Cancellable?
    private lazy var navigationBar = UINavigationBar()
    private lazy var navTitle = UINavigationItem()
    private lazy var placeholderImage = UIImage(systemName: "person.fill")?.scalePreservingAspectRatio(targetSize: CGSizeMake(100, 100)).withTintColor(.gray)
    private lazy var okAction = UIAlertAction(title: "OK", style: .default)
    private lazy var successAlert = UIAlertController(title: "Success!", message: "Data saved", preferredStyle: .alert)
    private lazy var failureAlert = UIAlertController(title: "Failure...", message: "Can't saved data", preferredStyle: .alert)
    private lazy var activityIndicator = UIActivityIndicatorView(style: .medium)
    
    private lazy var nameLabel: UILabel = {
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
    
    private lazy var initials: UILabel = {
        let label = UILabel()
        let initialFontSizeCalc = 150 * 0.45
        let descriptor = UIFont.systemFont(ofSize: initialFontSizeCalc, weight: .semibold).fontDescriptor.withDesign(.rounded)
        label.font = UIFont(descriptor: descriptor!, size: initialFontSizeCalc)
        label.textColor = .white
        let formatter = PersonNameComponentsFormatter()
        let components = formatter.personNameComponents(from: nameLabel.text ?? "")
        formatter.style = .abbreviated
        label.text = formatter.string(from: components!)
        return label
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
        nameLabel.textColor = themeService?.currentTheme.textColor
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: themeService?.currentTheme.textColor ?? .gray]
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
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
        let navCloseButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeProfileTapped))
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
        editableBioSection.text = bioText.text
        editableNameSection.text = nameLabel.text
        navTitle.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveProfile))
        nameLabel.isHidden = true
        bioText.isHidden = true
        editableNameSection.isHidden = false
        editableBioSection.isHidden = false
        navTitle.title = "Edit profile"
        nameCell.isHidden = false
        bioCell.isHidden = false
        editableNameSection.becomeFirstResponder()
    }
    
    private func setEditFinished() {
        nameCell.isHidden = true
        bioCell.isHidden = true
        editableNameSection.isHidden = true
        editableBioSection.isHidden = true
        editableNameSection.isEnabled = true
        editableBioSection.isEnabled = true
        addPhotoButton.isEnabled = true
        nameLabel.isHidden = false
        bioText.isHidden = false
        navTitle.title = "My Profile"
        navTitle.rightBarButtonItems?.removeAll()
        let navEditProfile = UIBarButtonItem(customView: editButton)
        navTitle.rightBarButtonItem = navEditProfile
    }
    
    private func setupProfile(profile: ProfileModel) {
        nameLabel.text = profile.fullName
        bioText.text = profile.statusText
        if profile.profileImageData == nil {
            userAvatar.image = placeholderImage
        } else {
            guard let imageData = profile.profileImageData else { return }
            userAvatar.image = UIImage(data: imageData)
        }
    }
    
    @objc
    private func saveProfile() {
        guard let bioText = editableBioSection.text,
              let nameText = editableNameSection.text
        else {
            return
        }
        
        var imageData: Data? = nil
        
        if self.profileImageView.image == placeholderImage {
            imageData = nil
        } else {
            imageData = self.profileImageView.image?.jpegData(compressionQuality: 1)
        }
        
        let profileToSave = ProfileModel(fullName: bioText, statusText: nameText, profileImageData: imageData)
        presenter?.updateProfile(profile: profileToSave)
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
        if activityIndicator.isAnimating == true {
            setEditFinished()
        } else if editableNameSection.isHidden == false {
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
        view.addSubviews(navigationBar, profileImageView, addPhotoButton, nameLabel, bioText, nameCell,bioCell)
        nameCell.addSubview(editableNameSection)
        bioCell.addSubview(editableBioSection)
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        addPhotoButton.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
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
            
            nameLabel.topAnchor.constraint(equalTo: addPhotoButton.bottomAnchor, constant: UIConstants.addPhotoToNameLabel),
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            bioText.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: UIConstants.nameLabelToInfoText),
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
    func showProfile() {
        profileRequest = profilePublisher
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveCancel: { print("Cancel sub in ProfileViewController") })
            .decode(type: ProfileModel.self, decoder: JSONDecoder())
            .catch({_ in Just(ProfileModel(fullName: "No name", statusText: "No bio", profileImageData: nil))})
            .map(State.profile)
            .assign(to: \.state, on: self)
    }
}
