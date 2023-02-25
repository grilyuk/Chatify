//
//  SecondViewController.swift
//  ChatTFS
//
//  Created by Григорий Данилюк on 18.02.2023.
//

import UIKit

class ProfileViewController: UIViewController, UINavigationBarDelegate {
    
    //MARK: Public properties
    public let profileImageView = UIImageView()
    
    //MARK: Private properties
    private let log = Logger(shouldLog: true, logType: .frame)
    private let alert = AlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    private let navigationBar = UINavigationBar()
    private let gradient = CAGradientLayer()
    private let addPhotoButton = UIButton(type: .system)
    private let fullNameLabel = UILabel()
    private let infoText = UITextView()
    private let userInitialsLabel = UILabel()
    
    //MARK: UIConstants
    private let UIConstants = UIConstant.self
    
    //MARK: Lifecycle
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
// здесь происходит инициализация нашего контроллера, о границах вьюшек не может идти и речи, так как мы еще даже не знаем есть они у нас или нет
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
        let frame = addPhotoButton.frame.debugDescription.description
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
// уже здесь, отработали методы AutoLayout'a и viewDid/WillLayoutSubviews
// эти методы в свою очередь как раз отвечают за вычисление границ и размеров наших
// viewDidAppear срабатывает уже после отображения на экране устройства
// поэтому во viewDidAppear мы уже видим итоговое значение frame нашей кнопки, так как предыдущие методы его вычислили
        let frame = addPhotoButton.frame.debugDescription.description
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
        fullNameLabel.text = "Grigoriy Danilyuk"
        fullNameLabel.font = UIFont.systemFont(ofSize: UIConstants.largerFontSize, weight: .bold)
        
        NSLayoutConstraint.activate([
            fullNameLabel.topAnchor.constraint(equalTo: addPhotoButton.bottomAnchor, constant: UIConstants.addPhotoToNameLabel),
            fullNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func setInfoText() {
        view.addSubview(infoText)
        infoText.translatesAutoresizingMaskIntoConstraints = false
        infoText.textAlignment = .center
        infoText.font = UIFont.systemFont(ofSize: UIConstants.fontSize, weight: .regular)
        infoText.textColor = .gray
        infoText.text = "Almost iOS Developer \nSaint-Petersburg, Russia"
        infoText.isScrollEnabled = false
        
        NSLayoutConstraint.activate([
            infoText.topAnchor.constraint(equalTo: fullNameLabel.bottomAnchor, constant: UIConstants.nameLabelToInfoText),
            infoText.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func setInitialsLabel() {
        view.addSubview(userInitialsLabel)
        userInitialsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        guard let initials = fullNameLabel.text else { return }
        userInitialsLabel.text = initials.components(separatedBy: " ")
            .reduce("") {($0 == "" ? "" : "\($0.first ?? " ")") + "\($1.first ?? " ")"}
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
