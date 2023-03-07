//
//  ConversationViewController.swift
//  ChatTFS
//
//  Created by Григорий Данилюк on 07.03.2023.
//

import UIKit

struct Dates: Hashable {
    let dateOfDay: Date
}

struct Message: Hashable {
    let sendTime: Date
}

class ConversationViewController: UIViewController {
    
    var messageData: [MessageCellModel] = [
    MessageCellModel(text: "My", date: Date(), myMessage: true),
    MessageCellModel(text: "Not", date: Date(), myMessage: false),
    MessageCellModel(text: "trw", date: Date(), myMessage: true)
    ]
    
    private lazy var tableView = UITableView()
    private lazy var dataSource = ConversationDataSource(tableView: tableView, messages: messageData)
    let dates = [
    Dates(dateOfDay: Date(timeIntervalSinceReferenceDate: 1000)),
    Dates(dateOfDay: Date(timeIntervalSinceReferenceDate: 10000)),
    Dates(dateOfDay: Date(timeIntervalSinceReferenceDate: 100000))
    ]
    
    let messages = [
        Message(sendTime: Date(timeIntervalSinceReferenceDate: 1000)),
        Message(sendTime: Date(timeIntervalSinceReferenceDate: 10000)),
        Message(sendTime: Date(timeIntervalSinceReferenceDate: 10000)),
        Message(sendTime: Date(timeIntervalSinceReferenceDate: 100000))
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }
    
    private func setupUI() {
        setTableView()
        setDataSource()
    }
    
    private func setDataSource() {
        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()
        snapshot.appendSections(dates)

        for date in dates {
            for message in messages {
                if message.sendTime == date.dateOfDay {
                    var arrMsg: [Message] = []
                    arrMsg.append(message)
                    snapshot.appendItems(arrMsg, toSection: date)
                }
            }
        }
        dataSource.apply(snapshot)
    }
    
    private func setTableView() {
        view.addSubview(tableView)
        tableView.register(ConversationViewCell.self, forCellReuseIdentifier: ConversationViewCell.identifier)
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        
//        tableView.separatorStyle = .none
        
        NSLayoutConstraint.activate([
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
    }
}

//MARK: ConversationViewController + UITableViewDelegate
extension ConversationViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: false)
    }
    
}
