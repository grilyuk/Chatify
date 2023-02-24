//
//  SecondViewController.swift
//  ChatTFS
//
//  Created by Григорий Данилюк on 18.02.2023.
//

import UIKit

class ProfileViewController: UIViewController, UINavigationBarDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    //MARK: Private properties
    private let log = Logger(shouldLog: true, logType: .frame)
    private let alert = AlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    private let navigationBar = UINavigationBar()
    private let profileImage = UIImageView()
    private let addPhotoButton = UIButton(type: .system)
    private let fullNameLabel = UILabel()
    private let infoText = UITextView()
    private let userInitialsLabel = UILabel()
    
    //MARK: UIConstants
    private let UIConstants = UIConstant.self
    
    //MARK: Lifecycle
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        let frame = addPhotoButton.frame.debugDescription.description
        log.handleFrame(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let frame = addPhotoButton.frame.debugDescription.description
        log.handleFrame(frame: frame)
        view.backgroundColor = .white
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let gradient = CAGradientLayer()
        gradient.colors = [UIConstants.imageProfileTopColor.cgColor, UIConstants.imageProfileBottomColor.cgColor]
        gradient.frame = profileImage.bounds
        profileImage.layer.addSublayer(gradient)
        profileImage.layer.cornerRadius = profileImage.frame.height / 2
        profileImage.clipsToBounds = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let frame = addPhotoButton.frame.debugDescription.description
        log.handleFrame(frame: frame)
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
        view.addSubview(profileImage)
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profileImage.widthAnchor.constraint(equalToConstant: UIConstants.imageProfileSize),
            profileImage.heightAnchor.constraint(equalToConstant: UIConstants.imageProfileSize),
            profileImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImage.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: UIConstants.navBarToProfileImage)
        ])
    }
    
    private func setAddPhotoButton() {
        view.addSubview(addPhotoButton)
        addPhotoButton.translatesAutoresizingMaskIntoConstraints = false
        addPhotoButton.setTitle("Add photo", for: .normal)
        addPhotoButton.titleLabel?.font = UIFont.systemFont(ofSize: UIConstants.fontSize)
        addPhotoButton.addTarget(self, action: #selector(addPhototapped), for: .touchUpInside)
        
        
        NSLayoutConstraint.activate([
            addPhotoButton.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: UIConstants.imageProfileToAddPhoto),
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
            userInitialsLabel.centerXAnchor.constraint(equalTo: profileImage.centerXAnchor),
            userInitialsLabel.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor)
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
