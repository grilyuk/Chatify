import UIKit
import Combine

protocol ProfileViewProtocol: AnyObject {
    var profilePhoto: UIImageView { get set }
    func showProfile()
}

class ProfileViewController: UIViewController {
    
    // MARK: - Initialization
    
    init(themeService: ThemeServiceProtocol, profilePublisher: CurrentValueSubject<ProfileModel, Never>) {
        self.themeService = themeService
        self.profilePublisher = profilePublisher
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIConstants
    
    private enum UIConstants {
        static let fontSize: CGFloat = 17
        static let largerFontSize: CGFloat = 22
        static let initialsFontSize: CGFloat = 68
        static let navBarToProfileImage: CGFloat = 32
        static let imageProfileSize: CGFloat = 150
        static let imageProfileToAddPhoto: CGFloat = 24
        static let addPhotoToNameLabel: CGFloat = 24
        static let nameLabelToInfoText: CGFloat = 10
        static let imageProfileTopColor: UIColor = #colorLiteral(red: 0.9541506171, green: 0.5699337721, blue: 0.6460854411, alpha: 1)
        static let imageProfileBottomColor: UIColor = #colorLiteral(red: 0.1823898468, green: 0.5700650811, blue: 0.6495155096, alpha: 1)
    }
    
    // MARK: - Public
    
    var profilePhoto = UIImageView()
    var presenter: ProfilePresenterProtocol?
    weak var themeService: ThemeServiceProtocol?

    // MARK: - Private
    
    private enum State {
        case loading
        case error
        case profile(ProfileModel)
        case profileUploaded(ProfileModel)

    }
    
    private var state: State = .loading {
        didSet {
            switch state {
            case .loading:
                self.activityIndicator.startAnimating()
                self.addPhotoButton.isEnabled = false
                self.editableNameSection.isEnabled = false
                self.editableBioSection.isEnabled = false
            case .profile(let profile):
                profileUploaded(profile: profile)
                self.setEditFinished()
            case .profileUploaded(let profile):
                profileUploaded(profile: profile)
                self.setEditFinished()
                self.tabBarController?.show(successAlert, sender: self)
            case .error:
                break
            }
        }
    }
    
    private var profilePublisher: CurrentValueSubject<ProfileModel, Never>
    private var profileRequest: Cancellable?
    private lazy var chooseSourceAlert = ChooseSourceAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    private lazy var placeholderImage = UIImage(systemName: "person.fill")?
        .scalePreservingAspectRatio(targetSize: CGSize(width: 100, height: 100)).withTintColor(.gray)
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
    
    private lazy var initials: UILabel = {
        let label = UILabel()
        let initialFontSizeCalc = 150 * 0.45
        let descriptor = UIFont.systemFont(ofSize: initialFontSizeCalc, weight: .semibold).fontDescriptor.withDesign(.rounded)
        guard let descriptor = descriptor else { return label }
        label.font = UIFont(descriptor: descriptor, size: initialFontSizeCalc)
        label.textColor = .white
        let formatter = PersonNameComponentsFormatter()
        let components = formatter.personNameComponents(from: nameLabel.text ?? "")
        formatter.style = .abbreviated
        guard let components = components else { return label }
        label.text = formatter.string(from: components)
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        successAlert.addAction(okAction)
        addPhotoButton.addTarget(self, action: #selector(addPhotoTapped), for: .touchUpInside)
        presenter?.viewReady()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = themeService?.currentTheme.backgroundColor
        bioText.textColor = themeService?.currentTheme.textColor
        bioText.backgroundColor = themeService?.currentTheme.backgroundColor
        nameLabel.textColor = themeService?.currentTheme.textColor
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: themeService?.currentTheme.textColor ?? .gray]
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profilePhoto.contentMode = .scaleAspectFill
        profilePhoto.layer.cornerRadius = profilePhoto.frame.height / 2
        profilePhoto.clipsToBounds = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        profileRequest?.cancel()
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        setNavBar()
        setNavBarButtons()
        setConstraints()
        setGesture()
    }
    
    // MARK: - Methods
    
    private func setGesture() {
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setNavBarButtons() {
        let navEditProfile = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editProfileTapped))
        navigationItem.rightBarButtonItem = navEditProfile
    }
    
    private func setNavBar() {
        navigationController?.navigationItem.title = "My Profile"
        navigationController?.navigationBar.prefersLargeTitles = true
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIConstants.fontSize,
                                                                                          weight: .bold)]
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: themeService?.currentTheme.textColor ?? .gray]
        UINavigationBar.appearance().standardAppearance = appearance
        navigationItem.leftBarButtonItem?.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont
            .systemFont(ofSize: UIConstants.fontSize, weight: .regular)], for: .normal)
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont
            .systemFont(ofSize: UIConstants.fontSize, weight: .regular)], for: .normal)
    }
    
    private func profileUploaded(profile: ProfileModel) {
        nameLabel.text = profile.fullName
        bioText.text = profile.statusText
        if profile.profileImageData == nil {
            profilePhoto.image = placeholderImage
        } else {
            guard let imageData = profile.profileImageData else { return }
            profilePhoto.image = UIImage(data: imageData)
        }
    }
    
    private func editableMode() {
        editableBioSection.text = bioText.text
        editableNameSection.text = nameLabel.text
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveProfile))
        nameLabel.isHidden = true
        bioText.isHidden = true
        editableNameSection.isHidden = false
        editableBioSection.isHidden = false
        navigationItem.title = "Edit profile"
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
        navigationItem.title = "My Profile"
        navigationItem.rightBarButtonItems?.removeAll()
        activityIndicator.stopAnimating()
        let navEditProfile = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editProfileTapped))
        navigationItem.rightBarButtonItem = navEditProfile
    }
    
    @objc
    private func saveProfile() {
        guard let bioText = editableBioSection.text,
              let nameText = editableNameSection.text
        else {
            return
        }
        
        var imageData: Data?
        
        if self.profilePhoto.image == placeholderImage {
            imageData = nil
        } else {
            imageData = self.profilePhoto.image?.jpegData(compressionQuality: 1)
        }
        
        let profileToSave = ProfileModel(fullName: nameText, statusText: bioText, profileImageData: imageData)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        state = .loading
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
        if editableNameSection.isHidden == false {
            setEditFinished()
        } else {
            self.dismiss(animated: true)
        }
    }
    
    @objc
    private func addPhotoTapped() {
        editableMode()
        tabBarController?.present(chooseSourceAlert, animated: true) {
            self.chooseSourceAlert.profileVC = self
        }
    }
    
    private func setConstraints() {
        view.addSubviews(profilePhoto, addPhotoButton, nameLabel, bioText, nameCell, bioCell)
        nameCell.addSubview(editableNameSection)
        bioCell.addSubview(editableBioSection)
        profilePhoto.translatesAutoresizingMaskIntoConstraints = false
        addPhotoButton.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameCell.translatesAutoresizingMaskIntoConstraints = false
        bioCell.translatesAutoresizingMaskIntoConstraints = false
        editableNameSection.translatesAutoresizingMaskIntoConstraints = false
        editableBioSection.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            profilePhoto.widthAnchor.constraint(equalToConstant: UIConstants.imageProfileSize),
            profilePhoto.heightAnchor.constraint(equalToConstant: UIConstants.imageProfileSize),
            profilePhoto.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profilePhoto.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: UIConstants.navBarToProfileImage),
            
            addPhotoButton.topAnchor.constraint(equalTo: profilePhoto.bottomAnchor, constant: UIConstants.imageProfileToAddPhoto),
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

// MARK: - ProfileViewController + ProfileViewProtocol

extension ProfileViewController: ProfileViewProtocol {
    func showProfile() {
        profileRequest = profilePublisher
            .map({ [weak self] profile in
                guard let self = self else { return State.error }
                if self.nameLabel.text == profile.fullName,
                   self.bioText.text == profile.statusText {
                    return State.profileUploaded(profile)
                } else {
                    return State.profile(profile)
                }
            })
            .assign(to: \.state, on: self)
    }
}
