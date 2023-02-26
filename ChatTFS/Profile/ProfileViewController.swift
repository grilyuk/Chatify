//
//  SecondViewController.swift
//  ChatTFS
//
//  Created by Григорий Данилюк on 18.02.2023.
//

import UIKit

protocol ProfileViewProtocol: AnyObject {
    func showProfile(profile: ProfileModel)
}

class ProfileViewController: UIViewController, UINavigationBarDelegate {
    var presenter: ProfilePresenterProtocol?
    private let log = Logger(shouldLog: true, logType: .frame)
    
    //MARK: Public
    public let profileImageView = UIImageView()
    
    //MARK: Private
    private let navigationBar = UINavigationBar()
    lazy var gradient = CAGradientLayer()
    private let addPhotoButton = UIButton(type: .system)
    private let fullNameLabel = UILabel()
    private let statusText = UITextView()
    private let userInitialsLabel = UILabel()

    //MARK: UIConstants
    private let UIConstants = UIConstant.self

    //MARK: Lifecycle
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
// здесь происходит инициализация нашего контроллера
// о границах вьюшек мы еще не знаем
        let frame = addPhotoButton.frame.debugDescription.description
        log.handleFrame(frame: frame, object: "addPhotoButton")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
// в данном методе ЖЦ, наши вьюшки уже занесены в память, но не отображены на экране
// здесь не происходят вычисления их границ, пока мы просто знаем что они у нас есть и дальше мы можем с ними работать
        presenter?.viewDidLoaded()
        let frame = addPhotoButton.frame.debugDescription
        log.handleFrame(frame: frame, object: "addPhotoButton")
        view.backgroundColor = .white
        setupUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if profileImageView.image == nil {
            gradient.colors = [UIConstants.imageProfileTopColor.cgColor,
                               UIConstants.imageProfileBottomColor.cgColor]
            gradient.frame = profileImageView.bounds
            profileImageView.layer.addSublayer(gradient)
        } else {
            gradient.removeFromSuperlayer()
            userInitialsLabel.isHidden = true
            profileImageView.contentMode = .scaleAspectFill
        }
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.clipsToBounds = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
// уже здесь, отработали методы AutoLayout'a и viewWill/DidLayoutSubviews
// эти методы в свою очередь как раз отвечают за вычисление границ и размеров наших вью
// viewDidAppear срабатывает уже после отображения на экране устройства
// поэтому во viewDidAppear мы уже видим итоговое значение frame нашей кнопки, так как его вычислили предыдущие методы 
        let frame = addPhotoButton.frame.debugDescription
        log.handleFrame(frame: frame, object: "addPhotoButton")
    }

    //MARK: Setup UI
    private func setupUI() {
        setNavBar()
        setProfileImage()
        setAddPhotoButton()
        setFullNameLabel()
        setInfoText()
        setInitialsLabel()
    }

    private func setNavBar() {
        view.addSubview(navigationBar)
        navigationBar.translatesAutoresizingMaskIntoConstraints = false

        let navTitle = UINavigationItem(title: "My Profile")
        let navCloseButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeProfileTapped))
        let navEditProfile = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editProfileTapped))

        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [ NSAttributedString.Key.font : UIFont.systemFont(ofSize: UIConstants.fontSize, weight: .bold)]
        UINavigationBar.appearance().standardAppearance = appearance

        navTitle.leftBarButtonItem = navCloseButton
        navTitle.rightBarButtonItem = navEditProfile
        navTitle.rightBarButtonItem?.setTitleTextAttributes([ NSAttributedString.Key.font : UIFont.systemFont(ofSize: UIConstants.fontSize, weight: .regular)], for: .normal)
        navTitle.leftBarButtonItem?.setTitleTextAttributes([ NSAttributedString.Key.font : UIFont.systemFont(ofSize: UIConstants.fontSize, weight: .regular)], for: .normal)
        navigationBar.setItems([navTitle], animated: false)

        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.widthAnchor.constraint(equalToConstant: view.frame.width),
            navigationBar.heightAnchor.constraint(greaterThanOrEqualToConstant: UIConstants.navBarHeight)
        ])
    }

    private func setProfileImage() {
        view.addSubview(profileImageView)
        profileImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            profileImageView.widthAnchor.constraint(equalToConstant: UIConstants.imageProfileSize),
            profileImageView.heightAnchor.constraint(equalToConstant: UIConstants.imageProfileSize),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: UIConstants.navBarToProfileImage)
        ])
    }

    private func setAddPhotoButton() {
        view.addSubview(addPhotoButton)
        addPhotoButton.translatesAutoresizingMaskIntoConstraints = false
        addPhotoButton.setTitle("Add photo", for: .normal)
        addPhotoButton.titleLabel?.font = UIFont.systemFont(ofSize: UIConstants.fontSize)
        addPhotoButton.addTarget(self, action: #selector(addPhototapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            addPhotoButton.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: UIConstants.imageProfileToAddPhoto),
            addPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func setFullNameLabel() {
        view.addSubview(fullNameLabel)
        fullNameLabel.translatesAutoresizingMaskIntoConstraints = false
        fullNameLabel.font = UIFont.systemFont(ofSize: UIConstants.largerFontSize, weight: .bold)

        NSLayoutConstraint.activate([
            fullNameLabel.topAnchor.constraint(equalTo: addPhotoButton.bottomAnchor, constant: UIConstants.addPhotoToNameLabel),
            fullNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func setInfoText() {
        view.addSubview(statusText)
        statusText.translatesAutoresizingMaskIntoConstraints = false
        statusText.textAlignment = .center
        statusText.font = UIFont.systemFont(ofSize: UIConstants.fontSize, weight: .regular)
        statusText.textColor = .gray
        statusText.isScrollEnabled = false

        NSLayoutConstraint.activate([
            statusText.topAnchor.constraint(equalTo: fullNameLabel.bottomAnchor, constant: UIConstants.nameLabelToInfoText),
            statusText.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func setInitialsLabel() {
        view.addSubview(userInitialsLabel)
        userInitialsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let formatter = PersonNameComponentsFormatter()
        guard let initials = fullNameLabel.text,
        let components = formatter.personNameComponents(from: initials) else { return }
        formatter.style = .abbreviated
        userInitialsLabel.text = formatter.string(from: components)
        userInitialsLabel.font = .rounded(ofSize: UIConstants.initialsFontSize, weight: .semibold)
        userInitialsLabel.textColor = .white

        NSLayoutConstraint.activate([
            userInitialsLabel.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor),
            userInitialsLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor)
        ])
    }

    @objc func editProfileTapped() {
        //temporary empty
    }

    @objc func closeProfileTapped() {
        self.dismiss(animated: true)
    }

    @objc func addPhototapped() {
        let alert = AlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        present(alert, animated: true) {
            alert.vc = self
        }
    }
}

//MARK: ProfileViewController + ProfileViewProtocol
extension ProfileViewController: ProfileViewProtocol {
    func showProfile(profile: ProfileModel) {
        self.fullNameLabel.text = profile.fullName
        self.statusText.text = profile.statusText
        self.profileImageView.image = profile.profileImage
    }
}
