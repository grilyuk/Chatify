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
    private lazy var tableView = UITableView(frame: .zero)
    private lazy var navigationBar = UINavigationBar()
    
    
    //MARK: Lifeсycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewReady()
        presenter?.didTappedProfile()
        let settingButton = UIBarButtonItem(image: UIImage(systemName: "gear")!, style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = settingButton
        setupUI()
    }

    //MARK: Setup UI
    private func setupUI() {
        
        view.addSubview(navigationBar)
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.backgroundColor = .white
        
        
        
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: 56),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.widthAnchor.constraint(equalToConstant: view.frame.width)
        ])
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

//MARK: MainViewController + MainViewProtocol
extension MainViewController: MainViewProtocol {
    func showMain() {
        view.backgroundColor = .white
    }
}
