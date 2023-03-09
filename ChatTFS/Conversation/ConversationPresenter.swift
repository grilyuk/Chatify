//
//  ConversationPresenter.swift
//  ChatTFS
//
//  Created by Григорий Данилюк on 07.03.2023.
//

import Foundation
import UIKit

protocol ConversationPresenterProtocol: AnyObject {
    func viewReady()
    func dataUploaded()
}

class ConversationPresenter {
    weak var view: ConversationViewProtocol?
    let router: RouterProtocol?
    let interactor: ConversationInteractorProtocol
    
    init(router: RouterProtocol, interactor: ConversationInteractorProtocol, conversation: IndexPath) {
        self.router = router
        self.interactor = interactor
    }
}

extension ConversationPresenter: ConversationPresenterProtocol {
    func viewReady() {
        interactor.loadData()
    }
    
    func dataUploaded() {
        view?.showConversation()
        
        guard let view = view as? ConversationViewController else { return }
        view.historyChat = [MessageCellModel(text: "Сёма, что там такое грохнуло на кухне?", date: Date(timeIntervalSinceNow: 0), myMessage: true),
                            MessageCellModel(text: " Люся, у меня случилось озарение: я видел будущее!", date: Date(timeIntervalSinceNow: 0), myMessage: false),
                            MessageCellModel(text: "И что там в будущем?", date: Date(timeIntervalSinceNow: 0), myMessage: true),
                            MessageCellModel(text: "Мы покупаем новую сахарницу.", date: Date(timeIntervalSinceNow: 0), myMessage: false),
                            MessageCellModel(text: "Да", date: Date(timeIntervalSinceNow: -412), myMessage: true),
                            MessageCellModel(text: "Не смешно \nТестим тестим тестим \nТестим тестим тестим\nТестим тестим тестим", date: Date(timeIntervalSinceNow: -2515), myMessage: true),
                            MessageCellModel(text: "Не смешно \nТестим тестим тестим \nТестим тестим тестим\nТестим тестим тестим", date: Date(timeIntervalSinceNow: -5151), myMessage: false),
                            MessageCellModel(text: "Не смешно \nТестим тестим тестим \nТестим тестим тестим\nТестим тестим тестим", date: Date(timeIntervalSinceNow: -412), myMessage: false),
                            MessageCellModel(text: "Не смешно \nТестим тестим тестим \nТестим тестим тестим\nТестим тестим тестим", date: Date(timeIntervalSinceNow: -5151), myMessage: true),
                            MessageCellModel(text: "Не смешно \nТестим тестим тестим \nТестим тестим тестим\nТестим тестим тестим", date: Date(timeIntervalSinceNow: -412), myMessage: false),
                            MessageCellModel(text: "Не смешно \nТестим тестим тестим \nТестим тестим тестим\nТестим тестим тестим", date: Date(timeIntervalSinceNow: 0), myMessage: true),
                            MessageCellModel(text: "Ok", date: Date(timeIntervalSinceNow: -52315), myMessage: true),
                            MessageCellModel(text: "Не смешно \nТестим тестим тестим \nТестим тестим тестим\nТестим тестим тестим", date: Date(timeIntervalSinceNow: -412), myMessage: true),
                            MessageCellModel(text: "Не смешно \nТестим тестим тестим \nТестим тестим тестим\nТестим тестим тестим", date: Date(timeIntervalSinceNow: -412), myMessage: true),
                            MessageCellModel(text: "Не смешно \nТестим тестим тестим \nТестим тестим тестим\nТестим тестим тестим", date: Date(timeIntervalSinceNow: -412), myMessage: true),
                            MessageCellModel(text: "Не смешно \nТестим тестим тестим \nТестим тестим тестим\nТестим тестим тестим", date: Date(timeIntervalSinceNow: -412), myMessage: false),
                            MessageCellModel(text: "Some text \nSome text\nSome text\nSome textgewgrgw", date: Date(timeIntervalSinceNow: -5452552), myMessage: true),
                            MessageCellModel(text: "Не смешно \nТестим тестим тестим \nТестим тестим тестим\nТестим тестим тестим", date: Date(timeIntervalSinceNow: -412), myMessage: true),
                            MessageCellModel(text: "Оп оп \nТестим тестим тестим \nТестим тестим тестим\nТестим тестим тестим", date: Date(timeIntervalSinceNow: 0), myMessage: false)
                            
        ]
    }
}
