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

    //MARK: UIConstants
    private enum UIConstants {
        static let fontSize: CGFloat = 17
        static let largerFontSize: CGFloat = 22
        static let initialsFontSize: CGFloat = 68
        static let navBarHeight: CGFloat = 56
        static let navBarToProfileImage: CGFloat = 32
        static let imageProfileSize: CGFloat = 150
        static let imageProfileToAddPhoto: CGFloat = 24
        static let addPhotoToNameLabel: CGFloat = 24
        static let nameLabelToInfoText: CGFloat = 10
        static let imageProfileTopColor: UIColor = UIColor(red: 241/255, green: 159/255, blue: 180/255, alpha: 1)
        static let imageProfileBottomColor: UIColor = UIColor(red: 238/255, green: 123/255, blue: 149/255, alpha: 1)
    }

    //MARK: Public
    public let profileImageView = UIImageView()
    
    //MARK: Private
    private let navigationBar = UINavigationBar()
    private let gradient = CAGradientLayer()
    private let addPhotoButton = UIButton(type: .system)
    private let fullNameLabel = UILabel()
    private let statusText = UITextView()
    private let userInitialsLabel = UILabel()


    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewReady()
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
        guard let descriptor = UIFont.systemFont(ofSize: UIConstants.initialsFontSize, weight: .semibold).fontDescriptor.withDesign(.rounded) else { return }
        userInitialsLabel.font = UIFont(descriptor: descriptor, size: UIConstants.initialsFontSize)
        userInitialsLabel.textColor = .white

        NSLayoutConstraint.activate([
            userInitialsLabel.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor),
            userInitialsLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor)
        ])
    }

    @objc private func editProfileTapped() {
        //temporary empty
    }

    @objc private func closeProfileTapped() {
        self.dismiss(animated: true)
    }

    @objc private func addPhototapped() {
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
