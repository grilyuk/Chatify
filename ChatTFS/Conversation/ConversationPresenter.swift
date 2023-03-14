//
//  ConversationPresenter.swift
//  ChatTFS
//
//  Created by Григорий Данилюк on 07.03.2023.
//

import UIKit

protocol ConversationPresenterProtocol: AnyObject {
    var handler: (([MessageCellModel]) -> Void)? { get set }
    func viewReady()
    func dataUploaded()
}

class ConversationPresenter {
    weak var view: ConversationViewProtocol?
    let router: RouterProtocol?
    let interactor: ConversationInteractorProtocol
    let conversation: ConversationListCellModel?
    var historyChat: [MessageCellModel]?
    var handler: (([MessageCellModel]) -> Void)?
    
    init(router: RouterProtocol, interactor: ConversationInteractorProtocol, conversation: ConversationListCellModel) {
        self.router = router
        self.interactor = interactor
        self.conversation = conversation
    }
}

extension ConversationPresenter: ConversationPresenterProtocol {
    func viewReady() {
        handler = { [weak self] history in
            self?.historyChat = history
        }
        interactor.loadData()
        let userName = conversation?.name ?? ""
        guard let historyChat = historyChat else {return}
        view?.handler?(historyChat, userName)
    }
    
    func dataUploaded() {
        view?.showConversation()
    }
}
