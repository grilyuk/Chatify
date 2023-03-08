//
//  MainPresenter.swift
//  ChatTFS
//
//  Created by Григорий Данилюк on 26.02.2023.
//

import UIKit

protocol MainPresenterProtocol: AnyObject {
    var profile: ProfileModel? { get set }
    func viewReady()
    func dataUploaded()
    func didTappedProfile()
    func didTappedConversation(for indexPath: IndexPath)
}

class MainPresenter {
    weak var view: MainViewProtocol?
    let router: RouterProtocol?
    let interactor: MainInteractorProtocol
    var profile: ProfileModel?
    
    init(router: RouterProtocol, interactor: MainInteractorProtocol) {
        self.router = router
        self.interactor = interactor
    }
}

extension MainPresenter: MainPresenterProtocol {
    func viewReady() {
        interactor.loadData()
    }
    
    func dataUploaded() {
        view?.users = [
            ConversationListCellModel(name: "Charis Clay", message: "I think Houdini did something like this once! Why, if I recall correctly, he was out of the hospital", date: Date.init(timeIntervalSinceNow: TimeInterval.init(floatLiteral: 20)), isOnline: false, hasUnreadMessages: nil),
            ConversationListCellModel(name: "Lacey Finch", message: nil, date: Date(timeIntervalSinceReferenceDate: 43225235), isOnline: false, hasUnreadMessages: nil),
            ConversationListCellModel(name: "Norma Carver", message: nil, date: nil, isOnline: true, hasUnreadMessages: nil),
            ConversationListCellModel(name: "Dawson Suarez", message: "Привет", date: nil, isOnline: false, hasUnreadMessages: nil),
            ConversationListCellModel(name: "Aminah Burch", message: "How are you?", date: nil, isOnline: false, hasUnreadMessages: nil),
            ConversationListCellModel(name: "Rodney Sharp", message: "Go to shop", date: nil, isOnline: true, hasUnreadMessages: nil),
            ConversationListCellModel(name: "Erin Duke", message: "Are you busy?", date: nil, isOnline: false, hasUnreadMessages: nil),
            ConversationListCellModel(name: "Mehmet Matthams", message: "Как дела?", date: nil, isOnline: false, hasUnreadMessages: nil),
            ConversationListCellModel(name: "Malik Rios", message: "Я с тобой не разговариваю...", date: nil, isOnline: true, hasUnreadMessages: nil),
            ConversationListCellModel(name: "Samantha Erickson", message: "Ладно", date: nil, isOnline: true, hasUnreadMessages: nil),
            ConversationListCellModel(name: "Sid Terry", message: "Hello", date: nil, isOnline: true, hasUnreadMessages: nil),
            ConversationListCellModel(name: "Lochlan Alexander", message: "Well that's encouraging.", date: nil, isOnline: false, hasUnreadMessages: nil),
            ConversationListCellModel(name: "Ishaan Matthews", message: "Hello", date: nil, isOnline: true, hasUnreadMessages: nil),
            ConversationListCellModel(name: "Jazmin Clayton", message: "Hello", date: nil, isOnline: true, hasUnreadMessages: nil),
            ConversationListCellModel(name: "Hamish Barker", message: "Hello", date: nil, isOnline: false, hasUnreadMessages: nil),
            ConversationListCellModel(name: "Kezia Finley", message: "Hello", date: nil, isOnline: false, hasUnreadMessages: nil),
            ConversationListCellModel(name: "Sylvia Cooper", message: "Hello", date: nil, isOnline: false, hasUnreadMessages: nil),
            ConversationListCellModel(name: "Erica Tate", message: "Hello", date: nil, isOnline: false, hasUnreadMessages: nil),
            ConversationListCellModel(name: "Liana Fitzgerald", message: "Hello", date: nil, isOnline: true, hasUnreadMessages: nil),
            ConversationListCellModel(name: "Aiza Fischer", message: "Hello", date: nil, isOnline: false, hasUnreadMessages: nil)
        ]
        view?.showMain()
    }
    
    func didTappedProfile() {
        guard let profile = profile else { return }
        router?.showProfile(profile: profile)
    }
    
    func didTappedConversation(for indexPath: IndexPath) {
        router?.showConversation(conversation: indexPath)
    }
}
