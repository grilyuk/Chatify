//
//  MainPresenter.swift
//  ChatTFS
//
//  Created by Григорий Данилюк on 26.02.2023.
//

import UIKit

protocol ConvListPresenterProtocol: AnyObject {
    var profile: ProfileModel? { get set }
    var users: [ConversationListCellModel]? { get set }
    var handler: ((ProfileModel, [ConversationListCellModel]) -> Void)? { get set }
    func viewReady()
    func dataUploaded()
    func didTappedProfile()
    func didTappedConversation(for conversation: ConversationListCellModel)
}

class ConvListPresenter {
    weak var view: ConvListViewProtocol?
    var router: RouterProtocol?
    let interactor: ConvListInteractorProtocol
    var profile: ProfileModel?
    var users: [ConversationListCellModel]?
    var handler: ((ProfileModel, [ConversationListCellModel]) -> Void)?
    
    init(router: RouterProtocol, interactor: ConvListInteractorProtocol) {
        self.router = router
        self.interactor = interactor
    }
}

extension ConvListPresenter: ConvListPresenterProtocol {
    
    func viewReady() {
        handler = { [weak self] meProfile, unsortUsers in
            self?.profile = meProfile
            self?.users = unsortUsers
        }
        
        interactor.loadData()

        var usersWithMessages: [ConversationListCellModel] = []
        var usersWithoutMessages: [ConversationListCellModel] = []
        guard let users = users else { return }
        for user in users {
            switch user.date != nil {
            case true: usersWithMessages.append(user)
            case false: usersWithoutMessages.append(user)
            }
        }
        
        var sortedUsers = usersWithMessages.sorted { $0.date ?? Date() > $1.date ?? Date() }
        sortedUsers.append(contentsOf: usersWithoutMessages)

        view?.handler?(sortedUsers)
    }
    
    func dataUploaded() {
        view?.showMain()
    }
    
    func didTappedProfile() {
        guard let profile = profile else { return }
        router?.showProfile(profile: profile)
    }
    
    func didTappedConversation(for conversation: ConversationListCellModel) {
        router?.showConversation(conversation: conversation)
    }
}
