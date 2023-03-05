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

    //MARK: UIConstants
    private enum UIConstants {
        static let rowHeight: CGFloat = 76
        static let sectionHeight: CGFloat = 44
    }
    
    //MARK: Public
    var presenter: MainPresenterProtocol?
    var users: [ConversationListCellModel] = []

    //MARK: Private
    private lazy var tableView = UITableView()
    private lazy var profileImageView = UIImageView()
    private lazy var dataSource = DataSource(tableView: tableView)
    private lazy var onlineUsers: [User] = []
    private lazy var offlineUsers: [User] = []
    
    //MARK: Lifeсycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewReady()
        setupUI()
    }

    //MARK: Setup UI
    private func setupUI() {
        setTableView()
        setNavBar()
        setDataSource()
        tableView.showsVerticalScrollIndicator = false
    }
    
    private func setTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ConverstionListCell.self, forCellReuseIdentifier: ConverstionListCell.identifier)
        tableView.delegate = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setNavBar() {
        navigationItem.title = "Chat"
        navigationController?.navigationBar.prefersLargeTitles = true
        let settingButton = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: nil)
        navigationItem.leftBarButtonItem = settingButton
        
        let profileButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(tappedProfile))
        navigationItem.rightBarButtonItem = profileButton
    }

    private func setDataSource() {
        var snapshot = dataSource.snapshot()
        for user in users {
            if user.isOnline == true {
                onlineUsers.append(User())
            } else {
                offlineUsers.append(User())
            }
        }
        snapshot.deleteAllItems()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(offlineUsers, toSection: .offline)
        snapshot.appendItems(onlineUsers, toSection: .online)
        dataSource.apply(snapshot)
    }
    
    @objc private func tappedProfile() {
        presenter?.didTappedProfile()
    }
}

//MARK: MainViewController + UITableViewDelegate
extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        UIConstants.sectionHeight
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UIConstants.rowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: MainViewController + MainViewProtocol
extension MainViewController: MainViewProtocol {
    func showMain() {
        view.backgroundColor = .white
    }
}
