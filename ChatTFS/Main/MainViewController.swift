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
    let log = Logger(shouldLog: false, logType: .viewController)

    //MARK: Private
    private let profileButton = UIButton(type: .system)

    //MARK: Lifeсycle
    override func loadView() {
        super.loadView()
        log.handleLog(actualState: nil, previousState: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidLoaded()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        log.handleLog(actualState: nil, previousState: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        log.handleLog(actualState: nil, previousState: nil)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        log.handleLog(actualState: nil, previousState: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        log.handleLog(actualState: nil, previousState: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        log.handleLog(actualState: nil, previousState: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        log.handleLog(actualState: nil, previousState: nil)
    }

    //MARK: Setup UI
    private func setupUI() {
        setProfileButton()
    }

    private func setProfileButton() {
        view.addSubview(profileButton)
        profileButton.translatesAutoresizingMaskIntoConstraints = false
        profileButton.setTitle("Show profile", for: .normal)
        profileButton.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        profileButton.addTarget(self, action: #selector(profileButtonTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            profileButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            profileButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    @objc func profileButtonTapped() {
        presenter?.didTappedProfile()
    }
}

//MARK: MainViewController + MainViewProtocol
extension MainViewController: MainViewProtocol {
    func showMain() {
        view.backgroundColor = .cyan
    }
}
