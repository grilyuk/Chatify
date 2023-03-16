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
    }
}
