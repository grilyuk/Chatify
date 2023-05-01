import UIKit
import Combine

protocol ProfileViewProtocol: AnyObject {
    var profilePhoto: UIImageView { get set }
    func showProfile(data: ProfileModel)
    func showNetworkImages()
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
    }
    
    // MARK: - Public properties
    
    var profilePhoto: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    var presenter: ProfilePresenterProtocol?
    weak var themeService: ThemeServiceProtocol?

    // MARK: - Private properties
    
    private var profilePublisher: CurrentValueSubject<ProfileModel, Never>
    private lazy var activityIndicator = UIActivityIndicatorView(style: .medium)
    private lazy var placeholderImage = UIImage(systemName: "person.fill")
    private lazy var turnOnAnimate = UILongPressGestureRecognizer(target: self, action: #selector(showAnimate))
    private lazy var turnOffAnimate = UILongPressGestureRecognizer(target: self, action: #selector(stopAnimate))
    private lazy var tapEditButton = UITapGestureRecognizer(target: self, action: #selector(editProfileTapped))
    private lazy var animationGroup = CAAnimationGroup()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: UIConstants.largerFontSize, weight: .bold)
        return label
    }()
    
    private lazy var bioTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.textColor = .systemGray3
        textView.textContainer.maximumNumberOfLines = 3
        textView.textAlignment = .center
        textView.font = UIFont.systemFont(ofSize: UIConstants.fontSize, weight: .regular)
        textView.isScrollEnabled = false
        return textView
    }()
    
    private lazy var addPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add photo", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: UIConstants.fontSize)
        return button
    }()
    
    private lazy var bubble: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit profile", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: UIConstants.fontSize)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.backgroundColor = .systemBlue
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profilePhoto.image = placeholderImage
        activityIndicator.startAnimating()
        editButton.addGestureRecognizer(turnOnAnimate)
        editButton.addGestureRecognizer(tapEditButton)
        addPhotoButton.addTarget(self, action: #selector(addPhotoTapped), for: .touchUpInside)
        presenter?.viewReady()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bubble.backgroundColor = themeService?.currentTheme.themeBubble
        view.backgroundColor = themeService?.currentTheme.backgroundColor
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        setNavBar()
        setConstraints()
    }
    
    // MARK: - Methods
    
    private func setNavBar() {
        self.title = "My Profile"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    @objc
    private func editProfileTapped() {
//        presenter?.editProfile()
    }
    
    @objc
    private func addPhotoTapped() {
        let chooseSourceAlert = ChooseSourceAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        tabBarController?.present(chooseSourceAlert, animated: true) {
            chooseSourceAlert.profileVC = self
        }
    }
    
    @objc
    private func showAnimate(_ sender: UILongPressGestureRecognizer) {
        let rotation = CAKeyframeAnimation(keyPath: "transform.rotation")
        rotation.values = [
            0.0,
            -CGFloat.pi / 10,
            0.0,
            CGFloat.pi / 10,
            0.0
        ]
        
        let position = CAKeyframeAnimation(keyPath: #keyPath(CALayer.position))
        position.values = [
            editButton.layer.position,
            CGPoint(x: editButton.center.x, y: editButton.center.y - 5),
            CGPoint(x: editButton.center.x - 5, y: editButton.center.y),
            CGPoint(x: editButton.center.x, y: editButton.center.y + 5),
            CGPoint(x: editButton.center.x + 5, y: editButton.center.y),
            editButton.layer.position
        ]
        
        animationGroup.animations = [rotation, position]
        animationGroup.duration = 0.3
        animationGroup.repeatCount = .infinity
        editButton.layer.add(animationGroup, forKey: "shake")
        editButton.removeGestureRecognizer(turnOnAnimate)
        editButton.addGestureRecognizer(turnOffAnimate)
    }
    
    @objc
    private func stopAnimate(_ sender: UILongPressGestureRecognizer) {
        let currentPosition = editButton.layer.presentation()?.value(forKeyPath: #keyPath(CALayer.position))
        let currentAngle = editButton.layer.presentation()?.value(forKeyPath: "transform.rotation")
        editButton.layer.removeAllAnimations()
        
        let endShakePosition = CABasicAnimation(keyPath: #keyPath(CALayer.position))
        endShakePosition.fromValue = currentPosition
        endShakePosition.toValue = editButton.center
        
        let endShakeRotation = CABasicAnimation(keyPath: "transform.rotation")
        
        endShakeRotation.fromValue = currentAngle
        endShakeRotation.toValue = 0.0
        
        let group = CAAnimationGroup()
        group.duration = 0.5
        group.animations = [endShakePosition, endShakeRotation]
        group.fillMode = .forwards
        
        editButton.layer.add(group, forKey: nil)
        editButton.addGestureRecognizer(turnOnAnimate)
        editButton.removeGestureRecognizer(turnOffAnimate)
    }
    
    private func setConstraints() {
        view.addSubview(bubble)
        bubble.addSubviews(profilePhoto, addPhotoButton, nameLabel, bioTextView, editButton)
        
        bubble.translatesAutoresizingMaskIntoConstraints = false
        profilePhoto.translatesAutoresizingMaskIntoConstraints = false
        addPhotoButton.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        bioTextView.translatesAutoresizingMaskIntoConstraints = false
        editButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            bubble.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            bubble.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            bubble.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            bubble.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 8 / 11),
            
            profilePhoto.widthAnchor.constraint(equalToConstant: UIConstants.imageProfileSize),
            profilePhoto.heightAnchor.constraint(equalToConstant: UIConstants.imageProfileSize),
            profilePhoto.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profilePhoto.topAnchor.constraint(equalTo: bubble.topAnchor, constant: 32),
            
            addPhotoButton.topAnchor.constraint(equalTo: profilePhoto.bottomAnchor, constant: UIConstants.imageProfileToAddPhoto),
            addPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: addPhotoButton.bottomAnchor, constant: UIConstants.addPhotoToNameLabel),
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            bioTextView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: UIConstants.nameLabelToInfoText),
            bioTextView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bioTextView.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 3 / 4),
            
            editButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            editButton.topAnchor.constraint(equalTo: bioTextView.bottomAnchor, constant: 16),
            editButton.bottomAnchor.constraint(equalTo: bubble.bottomAnchor, constant: -16),
            editButton.widthAnchor.constraint(equalTo: bubble.widthAnchor, multiplier: 3 / 4),
            editButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 1)
        ])
    }
}

// MARK: - ProfileViewController + ProfileViewProtocol

extension ProfileViewController: ProfileViewProtocol {
    func showProfile(data: ProfileModel) {
        _ = profilePublisher
            .sink { [weak self] profile in
                self?.nameLabel.text = profile.fullName
                self?.bioTextView.text = profile.statusText
                DispatchQueue.main.async { [weak self] in
                    self?.activityIndicator.stopAnimating()
                    guard let data = profile.profileImageData,
                          let self else {
                        return
                    }
                    self.profilePhoto.layer.cornerRadius = self.profilePhoto.frame.height / 2
                    self.profilePhoto.clipsToBounds = true
                    self.profilePhoto.image = UIImage(data: data)
                    self.view.layoutIfNeeded()
                }
            }
    }
    
    func showNetworkImages() {
        presenter?.showNetworkImages(navigationController: self.navigationController ?? UINavigationController(), vc: self)
    }
}
