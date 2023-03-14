//
//  FirstViewController.swift
//  ChatTFS
//
//  Created by Григорий Данилюк on 16.02.2023.
//

import UIKit

protocol ConvListViewProtocol: AnyObject {
    func showMain()
    var users: [ConversationListCellModel]? { get set }
    var handler:(([ConversationListCellModel]) -> Void)? { get set }
}

class ConvListViewController: UIViewController {

    //MARK: UIConstants
    private enum UIConstants {
        static let rowHeight: CGFloat = 76
        static let sectionHeight: CGFloat = 44
    }
    
    //MARK: Public
    var presenter: ConvListPresenterProtocol?
    var users: [ConversationListCellModel]?
    var handler: (([ConversationListCellModel]) -> Void)?
    var themeService: ThemeServiceProtocol?

    //MARK: Private
    private lazy var profileImageView = UIImageView()
    private lazy var dataSource = ConvListDataSource(tableView: tableView)
    private lazy var tableView = UITableView()
    private lazy var imageButton = UIImage()
    
    //MARK: Lifeсycle
    init(themeService: ThemeServiceProtocol) {
        self.themeService = themeService
        super.init(nibName: nil, bundle: nil)
        imageButton = ImageRender(fullName: "Grigoriy Danilyuk", size: CGSize(width: UIConstants.sectionHeight, height: UIConstants.sectionHeight)).render()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewReady()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
        view.backgroundColor = themeService?.currentTheme.backgroundColor
        self.tableView.backgroundColor = themeService?.currentTheme.backgroundColor
    }
    
    //MARK: Setup UI
    private func setupUI() {
        setTableView()
        setNavBar()
        setDataSource()
    }

    private func setTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ConverstionListCell.self, forCellReuseIdentifier: ConverstionListCell.identifier)
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        
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
        
        let settingButton = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(chooseThemes))
        navigationItem.leftBarButtonItem = settingButton
        
        let button = UIButton(type: .custom)
        button.setImage(imageButton, for: .normal)
        button.addTarget(self, action: #selector(tappedProfile), for: .touchUpInside)
        let profileButton = UIBarButtonItem(customView: button)
        profileButton.customView?.contentMode = .scaleToFill
        profileButton.customView?.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        profileButton.customView?.layer.cornerRadius = 22
        profileButton.customView?.clipsToBounds = true
        navigationItem.rightBarButtonItem = profileButton
    }

    @objc
    private func chooseThemes() {
        guard let themeService = themeService else { return }
        navigationController?.pushViewController(ThemesViewController(themeService: themeService) , animated: true)
    }
    
    @objc
    private func tappedProfile() {
        presenter?.didTappedProfile()
    }
    
    //MARK: SetDataSource
    private func setDataSource() {
        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()
        snapshot.appendSections([Section.online, Section.offline])
        guard let users = users else { return }
        for user in users {
            switch user.isOnline {
            case true:
                snapshot.appendItems([user], toSection: .online)
            case false:
                snapshot.appendItems([user], toSection: .offline)
            }
        }
        dataSource.apply(snapshot)
    }
}

//MARK: MainViewController + UITableViewDelegate
extension ConvListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let convListCell = cell as? ConverstionListCell else { return }
        convListCell.contentView.backgroundColor = themeService?.currentTheme.backgroundColor
        convListCell.lastMessageText.textColor = themeService?.currentTheme.textColor
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        UIConstants.sectionHeight
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UIConstants.rowHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var section = Section.offline
        switch indexPath.section {
        case 0:
            section = .online
        case 1:
            section = .offline
        default:
            break
        }
        let usersInSection = dataSource.snapshot().itemIdentifiers(inSection: section)
        presenter?.didTappedConversation(for: usersInSection[indexPath.row])
    }
}

//MARK: MainViewController + MainViewProtocol
extension ConvListViewController: ConvListViewProtocol {
    func showMain() {
        handler = { [weak self] value in
            self?.users = value
        }
        view.backgroundColor = themeService?.currentTheme.backgroundColor
    }
}
