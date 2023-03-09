//
//  ConversationViewController.swift
//  ChatTFS
//
//  Created by Григорий Данилюк on 07.03.2023.
//

import UIKit

protocol ConversationViewProtocol: AnyObject {
    func showConversation()
    var historyChat: [MessageCellModel] {get set}
}

class ConversationViewController: UIViewController {
    var historyChat: [MessageCellModel] = []
    var titlesSections: [String] = []
    
    //MARK: UIConstants
    private enum UIConstants {
        static let borderWidth: CGFloat = 2
        static let textFieldHeight: CGFloat = 36
    }
    
    //MARK: Public
    var presenter: ConversationPresenterProtocol?
    
    //MARK: Private
    private lazy var dataSource = ConversationDataSource(tableView: tableView)
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.register(ConversationViewCell.self, forCellReuseIdentifier: ConversationViewCell.identifier)
        table.delegate = self
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 100
        table.separatorStyle = .none
        return table
    }()
    
    private lazy var textFieldView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = UIConstants.textFieldHeight/2
        view.layer.borderWidth = UIConstants.borderWidth
        view.layer.borderColor = UIColor.systemGray5.cgColor
        return view
    }()
    
    private lazy var textField: UITextField = {
        let field = UITextField()
        field.placeholder = "Type message"
        return field
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        let arrowImage = UIImage(systemName: "arrow.up.circle.fill")
        button.setImage(arrowImage, for: .normal)
        return button
    }()
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewReady()
        setDataSource()
        setTableView()
        setNavBar()
        setGesture()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showKeyboard),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(hideKeyboard),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    private func setGesture() {
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    private func setDataSource() {
        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd:MM:yyyy"
        
        let groupedMessages = Dictionary(grouping: historyChat, by: { Calendar.current.startOfDay(for: $0.date) })
        groupedMessages.keys.sorted().forEach { date in
            titlesSections.append(formatter.string(from: date))
            snapshot.appendSections([date])
            snapshot.appendItems(groupedMessages[date] ?? [])
        }
        dataSource.apply(snapshot)
    }
    
    //MARK: Setup UI
    private func setNavBar() {
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.title = "Непобедимый навбар"
        let avatarUser = UIImageView(image: UIImage(systemName: "gear") )
        navigationItem.titleView = avatarUser
    }
    
    private func setTableView() {
        view.addSubview(tableView)
        view.addSubview(textFieldView)
        textFieldView.addSubview(textField)
        textFieldView.addSubview(sendButton)
        
        textFieldView.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.bottomAnchor.constraint(equalTo: textFieldView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            
            textFieldView.heightAnchor.constraint(equalToConstant: UIConstants.textFieldHeight),
            textFieldView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            textFieldView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            textFieldView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            textField.bottomAnchor.constraint(equalTo: textFieldView.bottomAnchor, constant: -5),
            textField.topAnchor.constraint(equalTo: textFieldView.topAnchor, constant: 5),
            textField.leadingAnchor.constraint(equalTo: textFieldView.leadingAnchor, constant: 10),
            textField.trailingAnchor.constraint(equalTo: textFieldView.trailingAnchor, constant: -10),
            
            sendButton.heightAnchor.constraint(equalTo: textField.heightAnchor),
            sendButton.centerYAnchor.constraint(equalTo: textField.centerYAnchor),
            sendButton.trailingAnchor.constraint(equalTo: textField.trailingAnchor),
            sendButton.widthAnchor.constraint(equalTo: textField.heightAnchor)
        ])
    }
    
    @objc
    private func showKeyboard(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {return}

        let keyboardHeight = keyboardFrame.height
        let viewYMax = view.frame.maxY
        let safeAreaYMax = view.safeAreaLayoutGuide.layoutFrame.maxY
        let height = viewYMax - safeAreaYMax
        let offset = keyboardHeight - height
        additionalSafeAreaInsets.bottom = offset
    }

    @objc
    private func hideKeyboard(_ notification: Notification) {
        additionalSafeAreaInsets.bottom = 0
    }
    
    @objc
    private func dismissKeyboard() {
        view.endEditing(true)
    }
}

//MARK: ConversationViewController + UITableViewDelegate
extension ConversationViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let title = UILabel()
        title.text = titlesSections[section]
        title.backgroundColor = .init(white: 1, alpha: 0.8)
        title.font = .systemFont(ofSize: 12)
        title.textAlignment = .center
        return title
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

//MARK: ConversationViewController + ConversationViewProtocol
extension ConversationViewController: ConversationViewProtocol {
    
    func showConversation() {
        view.backgroundColor = .white
    }
}
