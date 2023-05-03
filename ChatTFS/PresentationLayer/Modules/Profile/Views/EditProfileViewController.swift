import UIKit

class EditProfileViewController: UIViewController {
    
    // MARK: - Initialization
    
    init(profile: ProfileModel, profileImage: UIImage, view: ProfileViewController) {
        self.actualProfile = profile
        self.actualImage = profileImage
        self.profileView = view
        self.themeService = view.themeService
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
    }
    
    // MARK: - Public properties
    
    var actualProfile: ProfileModel
    var actualImage: UIImage
    var profileView: ProfileViewController
    lazy var router: RouterProtocol? = profileView.presenter?.router
    weak var themeService: ThemeServiceProtocol?
    
    lazy var profilePhoto: UIImageView = {
        let imageView = UIImageView()
        imageView.image = actualImage
        imageView.layer.cornerRadius = UIConstants.imageProfileSize / 2
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    // MARK: - Private properties
    
    private lazy var addPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add photo", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: UIConstants.fontSize)
        button.addTarget(self, action: #selector(addPhotoTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Name"
        return label
    }()
    
    private lazy var bioLabel: UILabel = {
        let label = UILabel()
        label.text = "Bio"
        return label
    }()
    
    private lazy var bubble: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var separatorLine: UIView = {
        let view = UIView(frame: CGRect(x: 16, y: 44,
                                        width: view.frame.width,
                                        height: 1))
        view.backgroundColor = .systemGray3
        return view
    }()
    
    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.text = actualProfile.fullName
        textField.placeholder = "Type your name..."
        return textField
    }()
    
    private lazy var bioTextField: UITextField = {
        let textField = UITextField()
        textField.text = actualProfile.statusText
        textField.placeholder = "Designer from San Francisco..."
        return textField
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedOutside()
        setupUI()
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = themeService?.currentTheme.backgroundColor
        bubble.backgroundColor = themeService?.currentTheme.themeBubble
        bubble.layer.borderColor = separatorLine.backgroundColor?.cgColor
    }
    
    private func setupNavigationBar() {
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel,
                                           target: self,
                                           action: #selector(close))
        let saveButton = UIBarButtonItem(title: "Save",
                                         style: .plain,
                                         target: self,
                                         action: #selector(save))
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = saveButton
        navigationItem.title = "Edit profile"
    }
    
    private func setupUI() {
        view.addSubviews(profilePhoto, addPhotoButton, bubble)
        bubble.addSubviews(nameLabel, bioLabel, separatorLine, nameTextField, bioTextField)
        
        profilePhoto.translatesAutoresizingMaskIntoConstraints = false
        addPhotoButton.translatesAutoresizingMaskIntoConstraints = false
        bubble.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        bioLabel.translatesAutoresizingMaskIntoConstraints = false
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        bioTextField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profilePhoto.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: UIConstants.navBarToProfileImage),
            profilePhoto.widthAnchor.constraint(equalToConstant: UIConstants.imageProfileSize),
            profilePhoto.heightAnchor.constraint(equalToConstant: UIConstants.imageProfileSize),
            profilePhoto.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            addPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addPhotoButton.topAnchor.constraint(equalTo: profilePhoto.bottomAnchor, constant: UIConstants.imageProfileToAddPhoto),
            
            bubble.topAnchor.constraint(equalTo: addPhotoButton.bottomAnchor, constant: UIConstants.addPhotoToNameLabel),
            bubble.widthAnchor.constraint(equalToConstant: view.frame.width + 2),
            bubble.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bubble.heightAnchor.constraint(equalToConstant: 88),
            
            nameLabel.centerYAnchor.constraint(equalTo: bubble.topAnchor, constant: 22),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            bioLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor, constant: 44),
            bioLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 120),
            nameTextField.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            bioTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 120),
            bioTextField.centerYAnchor.constraint(equalTo: bioLabel.centerYAnchor)
        ])
    }
    
    func showNetworkImages() {
        guard let navigationController = self.navigationController else {
            return
        }
        router?.showNetworkImages(navigationController: navigationController, vc: self)
    }
    
    @objc
    private func save() {
        let newProfile = ProfileModel(fullName: nameTextField.text,
                                      statusText: bioTextField.text,
                                      profileImageData: profilePhoto.image?.jpegData(compressionQuality: 0.5))
        profileView.presenter?.updateProfile(profile: newProfile)
    }
    
    @objc
    private func addPhotoTapped() {
        let chooseSourceAlert = ChooseSourceAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        self.present(chooseSourceAlert, animated: true) {
            chooseSourceAlert.profileVC = self
        }
    }
    
    @objc
    private func close() {
//        navigationController?.popToRootViewController(animated: true)
        dismiss(animated: true)
    }
}
