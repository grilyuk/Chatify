//
//  ConversationInteractor.swift
//  ChatTFS
//
//  Created by Григорий Данилюк on 07.03.2023.
//

import Foundation

protocol ConversationInteractorProtocol: AnyObject {
    func loadData()
}

class ConversationInteractor: ConversationInteractorProtocol {
    var presenter: ConversationPresenterProtocol?
    
    func loadData() {
        presenter?.dataUploaded()
    }
}
