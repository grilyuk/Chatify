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
    private let profileButton = UIButton(type: .system)

    //MARK: Lifeсycle

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewReady()
        setupUI()
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

extension MainViewController {
    static func build() -> MainViewController {
        let interactor = MainInteractor()
        let view = MainViewController()
        let router = Router()
        let presenter = MainPresenter(router: router, interactor: interactor)
        router.view = view
        view.presenter = presenter
        interactor.presenter = presenter
        presenter.view = view
        return view
    }
}
