//
//  ConversationViewController.swift
//  ChatTFS
//
//  Created by Григорий Данилюк on 07.03.2023.
//

import UIKit

protocol ConversationViewProtocol: AnyObject {
    func showConversation()
    var messages: [MessageCellModel] {get set}
}

struct DaySection: Hashable {
    let dateOfDay: Date
}

struct Message: Hashable {
    let date: Date
    let id = UUID()
}

class ConversationViewController: UIViewController {
    
    var messages: [MessageCellModel] = [
        MessageCellModel(text: "Привет \nПривет \nПривет", date: Date(timeIntervalSinceReferenceDate: 1000), myMessage: false),
        MessageCellModel(text: "Нет, не получится.", date: Date(timeIntervalSinceReferenceDate: 10000), myMessage: true),
        MessageCellModel(text: "Hello world", date: Date(timeIntervalSinceReferenceDate: 100000), myMessage: true),
        MessageCellModel(text: "Хорошо, думаю получится.", date: Date(timeIntervalSinceReferenceDate: 10000), myMessage: true),
        MessageCellModel(text: "Нет, не получится.", date: Date(timeIntervalSinceReferenceDate: 10000), myMessage: true),
        MessageCellModel(text: "Нет, не получится.", date: Date(timeIntervalSinceReferenceDate: 10000), myMessage: true),
        MessageCellModel(text: "Нет, не получится.", date: Date(timeIntervalSinceReferenceDate: 10000), myMessage: true),
        ]
    var presenter: ConversationPresenterProtocol?
    
    private lazy var tableView = UITableView()
    private lazy var dataSource = ConversationDataSource(tableView: tableView, messages: messages)
    let dates = [
    DaySection(dateOfDay: Date(timeIntervalSinceReferenceDate: 1000)),
    DaySection(dateOfDay: Date(timeIntervalSinceReferenceDate: 10000)),
    DaySection(dateOfDay: Date(timeIntervalSinceReferenceDate: 100000))
    ]
    
    let messagesModels = [
        Message(date: Date(timeIntervalSinceReferenceDate: 1000)),
        Message(date: Date(timeIntervalSinceReferenceDate: 10000)),
        Message(date: Date(timeIntervalSinceReferenceDate: 10000)),
        Message(date: Date(timeIntervalSinceReferenceDate: 10000)),
        Message(date: Date(timeIntervalSinceReferenceDate: 100000))
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewReady()
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
            var arrMsg: [Message] = []
            for message in messagesModels {
                if message.date == date.dateOfDay {
                    arrMsg.append(message)
                    print(arrMsg.count)
                }
            }
            snapshot.appendItems(arrMsg, toSection: date)
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
        tableView.separatorStyle = .none
        
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

extension ConversationViewController: ConversationViewProtocol {
    func showConversation() {
        view.backgroundColor = .white
    }
}

