//
//  ConversationViewController.swift
//  ChatTFS
//
//  Created by Григорий Данилюк on 07.03.2023.
//

import UIKit

protocol ConversationViewProtocol: AnyObject {
    func showConversation()
    static var messages: [MessageCellModel] {get set}
}

struct DaySection: Hashable {
    let dateOfDay: Date
//    let id = UUID()
}

struct Message: Hashable {
    let date: Date
    let number: Int
    let id = UUID()
}

class ConversationViewController: UIViewController {
    
    //    тут я попытался в логику и хотел распределить сообщения по секциям
    //    секции с датами тоже хотел генерить, но не придумал как
    //    ощущение что я туплю и все гораздно проще, да и вообще какая то херь вышла по итогу
    //    мне плохо от этого кода
    //    полагаю что не очень хорошо разобрался с DiffableDataSource
    //    но я в любом случае это допилю, челов с кофекода спрошу, надеюсь помогут
    
    static var messages: [MessageCellModel] = [
        MessageCellModel(text: "Привет",
                         date: Date(timeIntervalSinceReferenceDate: 10000),
                         myMessage: false),
        MessageCellModel(text: "Нет, не получится.",
                         date: Date(timeIntervalSinceReferenceDate: 10000),
                         myMessage: true),
        MessageCellModel(text: "Hello world",
                         date: Date(timeIntervalSinceReferenceDate: 10000),
                         myMessage: false),
        MessageCellModel(text: "Я в своем познании настолько преисполнился, что я как будто бы уже сто триллионов миллиардов лет проживаю на триллионах и триллионах таких же планет, как эта Земля, мне этот мир абсолютно понятен, и я здесь ищу только одного - покоя, умиротворения и вот этой гармонии, от слияния с бесконечно вечным, от созерцания великого фрактального подобия и от вот этого замечательного всеединства существа, бесконечно вечного, куда ни посмотри, хоть вглубь - бесконечно малое, хоть ввысь - бесконечное большое, понимаешь?",
                         date: Date(timeIntervalSinceReferenceDate: 10000),
                         myMessage: true),
        MessageCellModel(text: "ММмм как же превосходно работаем таблица",
                         date: Date(timeIntervalSinceReferenceDate: 10000),
                         myMessage: true),
        MessageCellModel(text: "Why? I'm pretty good at cursing already.",
                         date: Date(timeIntervalSinceReferenceDate: 10000),
                         myMessage: false),
        MessageCellModel(text: "Test", date: Date(timeIntervalSinceReferenceDate: 10000),
                         myMessage: true),
        MessageCellModel(text: "Ok.", date: Date(timeIntervalSinceReferenceDate: 100000),
                         myMessage: true),
        MessageCellModel(text: "Why? I'm pretty good at cursing already.",
                         date: Date(timeIntervalSinceReferenceDate: 10000),
                         myMessage: false),
        MessageCellModel(text: "Why? I'm pretty good at cursing already.",
                         date: Date(timeIntervalSinceReferenceDate: 10000),
                         myMessage: true),
        MessageCellModel(text: "Я в своем познании настолько преисполнился, что я как будто бы уже сто триллионов миллиардов лет проживаю на триллионах и триллионах таких же планет, как эта Земля, мне этот мир абсолютно понятен, и я здесь ищу только одного - покоя, умиротворения и вот этой гармонии, от слияния с бесконечно вечным, от созерцания великого фрактального подобия и от вот этого замечательного всеединства существа, бесконечно вечного, куда ни посмотри, хоть вглубь - бесконечно малое, хоть ввысь - бесконечное большое, понимаешь?",
                         date: Date(timeIntervalSinceReferenceDate: 10000),
                         myMessage: false),
        MessageCellModel(text: "We've got to work on your cursing.",
                         date: Date(timeIntervalSinceReferenceDate: 10000),
                         myMessage: true),
        MessageCellModel(text: "Я в своем познании настолько преисполнился, что я как будто бы уже сто триллионов миллиардов лет проживаю на триллионах и триллионах таких же планет, как эта Земля, мне этот мир абсолютно понятен, и я здесь ищу только одного - покоя, умиротворения и вот этой гармонии, от слияния с бесконечно вечным, от созерцания великого фрактального подобия и от вот этого замечательного всеединства существа, бесконечно вечного, куда ни посмотри, хоть вглубь - бесконечно малое, хоть ввысь - бесконечное большое, понимаешь?",
                         date: Date(timeIntervalSinceReferenceDate: 10000),
                         myMessage: false),
        MessageCellModel(text: "Я в своем познании настолько преисполнился, что я как будто бы уже сто триллионов миллиардов лет проживаю на триллионах и триллионах таких же планет, как эта Земля, мне этот мир абсолютно понятен, и я здесь ищу только одного - покоя, умиротворения и вот этой гармонии, от слияния с бесконечно вечным, от созерцания великого фрактального подобия и от вот этого замечательного всеединства существа, бесконечно вечного, куда ни посмотри, хоть вглубь - бесконечно малое, хоть ввысь - бесконечное большое, понимаешь?",
                         date: Date(timeIntervalSinceReferenceDate: 1000000),
                         myMessage: true)
    ]
    
    let dates = [
        DaySection(dateOfDay: Date(timeIntervalSinceReferenceDate: 1000)),
        DaySection(dateOfDay: Date(timeIntervalSinceReferenceDate: 10000)),
        DaySection(dateOfDay: Date(timeIntervalSinceReferenceDate: 100000))
    ]
    
    let sectionsArray: Set<String> = {
        var array: Set<String> = []
        var i: Int = 0
        var k: Int = 0
        while i != messages.count {
            while k != messages.count {
                if messages[i].date == messages[k].date {
                    let date = messages[k].date
                    let format = DateFormatter()
                    format.dateFormat = "dd:MM:yyyy"
                    array.insert(format.string(from: date))
                }
                k += 1
            }
            i += 1
        }
        return array
    }()
    
//    let dates: Set<DaySection> = {
//        var array: Set<DaySection> = []
//        var i: Int = 0
//        var k: Int = 0
//        while i != messages.count {
//            while k != messages.count {
//                if messages[i].date == messages[k].date {
//                    let date = messages[k].date
//                    array.insert(DaySection(dateOfDay: date))
//                }
//                k += 1
//            }
//            i += 1
//        }
//        print(array.count)
//        return array
//    }()
    
    let messagesModels: [Message] = {
        var array: [Message] = []
        var number = 0
        for message in messages {
            let dateOfDay = Message(date: message.date, number: number)
            array.append(dateOfDay)
            number += 1
        }
        return array
    }()
    //    здесь попытки кончились, выглядит ужасно, но я хз как это адекватно сделать
    //    явно это можно сделать легче, но DiffableDataSource тяжело дается
    
    //MARK: UIConstants
    private enum UIConstants {
        static let borderWidth: CGFloat = 2
        static let textFieldHeight: CGFloat = 36
    }
    
    //MARK: Public
    var presenter: ConversationPresenterProtocol?
    
    //MARK: Private
    private lazy var tableView = UITableView()
    private lazy var dataSource = ConversationDataSource(tableView: tableView,
                                                         messages: ConversationViewController.messages)
    private lazy var textFieldView = UIView()
    private lazy var textField = UITextField()
    private lazy var sendButton = UIButton(type: .system)
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewReady()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showKeyboard),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        setupUI()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func showKeyboard(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {return}

        let keyboardHeight = keyboardFrame.height
        let viewYMax = view.frame.maxY
        let safeAreaYMax = view.safeAreaLayoutGuide.layoutFrame.maxY
        let height = viewYMax - safeAreaYMax
        let offset = keyboardHeight - height
        additionalSafeAreaInsets.bottom = offset
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        additionalSafeAreaInsets.bottom = 0
    }
                            
    //MARK: DataSource
    private func setDataSource() {
        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()
        snapshot.appendSections(Array(dates))
        for date in dates {
            var arrMsg: [Message] = []
            for message in messagesModels {
                if message.date == date.dateOfDay {
                    arrMsg.append(message)
                }
            }
            snapshot.appendItems(arrMsg, toSection: date)
        }
        dataSource.apply(snapshot)
    }
    
    //MARK: Setup UI
    private func setupUI() {
        setTableView()
        setDataSource()
        setNavBar()
        setTextFieldView()
        setTextField()
        setSendButton()
    }
    
    private func setNavBar() {
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.title = "Непобедимый навбар"
        let avatarUser = UIImageView(image: UIImage(systemName: "gear") )
        navigationItem.titleView = avatarUser
    }
    
    private func setTextFieldView() {
        textFieldView.layer.cornerRadius = UIConstants.textFieldHeight/2
        textFieldView.layer.borderWidth = UIConstants.borderWidth
        textFieldView.layer.borderColor = UIColor.systemGray5.cgColor
    }
    
    private func setTextField() {
        textField.placeholder = "Type message"
        textFieldView.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textField.bottomAnchor.constraint(equalTo: textFieldView.bottomAnchor, constant: -5),
            textField.topAnchor.constraint(equalTo: textFieldView.topAnchor, constant: 5),
            textField.leadingAnchor.constraint(equalTo: textFieldView.leadingAnchor, constant: 10),
            textField.trailingAnchor.constraint(equalTo: textFieldView.trailingAnchor, constant: -10)
        ])
    }
    
    private func setSendButton() {
        let arrowImage = UIImage(systemName: "arrow.up.circle.fill")
        sendButton.setImage(arrowImage, for: .normal)
        
        textFieldView.addSubview(sendButton)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            sendButton.heightAnchor.constraint(equalTo: textField.heightAnchor),
            sendButton.centerYAnchor.constraint(equalTo: textField.centerYAnchor),
            sendButton.trailingAnchor.constraint(equalTo: textField.trailingAnchor),
            sendButton.widthAnchor.constraint(equalTo: textField.heightAnchor)
        ])
    }
    
    private func setTableView() {
        tableView.register(ConversationViewCell.self, forCellReuseIdentifier: ConversationViewCell.identifier)
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.separatorStyle = .none
        
        view.addSubview(tableView)
        view.addSubview(textFieldView)
        textFieldView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.bottomAnchor.constraint(equalTo: textFieldView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textFieldView.heightAnchor.constraint(equalToConstant: UIConstants.textFieldHeight),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textFieldView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            textFieldView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            textFieldView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])
    }
}

//MARK: ConversationViewController + UITableViewDelegate
extension ConversationViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let title = UILabel()
        title.text = "Section"
        title.backgroundColor = .init(white: 1, alpha: 0.8)
        title.font = .systemFont(ofSize: 12)
        title.textAlignment = .center
        return title
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
