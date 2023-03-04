//
//  FirstViewController.swift
//  ChatTFS
//
//  Created by Григорий Данилюк on 16.02.2023.
//

import UIKit

protocol MainViewProtocol: AnyObject {
    func showMain()
}

class MainViewController: UIViewController {

    //MARK: Public
    var presenter: MainPresenterProtocol?

    //MARK: Private
    private lazy var profileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Show profile", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        return button
    }()

    //MARK: Lifeсycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewReady()
        setupUI()
        profileButton.addTarget(self, action: #selector(profileButtonTapped), for: .touchUpInside)
    }

    //MARK: Setup UI
    private func setupUI() {
        setProfileButton()
    }

    private func setProfileButton() {
        view.addSubview(profileButton)
        profileButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            profileButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    @objc private func profileButtonTapped() {
        presenter?.didTappedProfile()
    }
}

//MARK: MainViewController + MainViewProtocol
extension MainViewController: MainViewProtocol {
    func showMain() {
        view.backgroundColor = .cyan
    }
}
