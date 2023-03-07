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
            ConversationListCellModel(name: "Jhon Travolta", message: "Hello", date: Date.init(timeIntervalSinceNow: TimeInterval.init(floatLiteral: 20)), isOnline: false, hasUnreadMessages: nil),
            ConversationListCellModel(name: "Ferb", message: nil, date: Date(timeIntervalSinceReferenceDate: 43225235), isOnline: false, hasUnreadMessages: nil),
            ConversationListCellModel(name: "Stevene", message: "Some message", date: nil, isOnline: true, hasUnreadMessages: nil),
            ConversationListCellModel(name: "Danil", message: "Привет", date: nil, isOnline: false, hasUnreadMessages: nil),
            ConversationListCellModel(name: "Stefan", message: "How are you?", date: nil, isOnline: false, hasUnreadMessages: nil),
            ConversationListCellModel(name: "Robert", message: "Go to shop", date: nil, isOnline: true, hasUnreadMessages: nil),
            ConversationListCellModel(name: "Alex", message: "Are you busy?", date: nil, isOnline: false, hasUnreadMessages: nil),
            ConversationListCellModel(name: "Nika", message: "Как дела?", date: nil, isOnline: false, hasUnreadMessages: nil),
            ConversationListCellModel(name: "Lena", message: "Я с тобой не разговариваю...", date: nil, isOnline: true, hasUnreadMessages: nil),
            ConversationListCellModel(name: "Alyona", message: "Ладно", date: nil, isOnline: true, hasUnreadMessages: nil),
            ConversationListCellModel(name: "Sandra Safa", message: "Hello", date: nil, isOnline: true, hasUnreadMessages: nil),
            ConversationListCellModel(name: "Gret Fasf", message: "Hello", date: nil, isOnline: false, hasUnreadMessages: nil),
            ConversationListCellModel(name: "Dsd G", message: "Hello", date: nil, isOnline: false, hasUnreadMessages: nil),
            ConversationListCellModel(name: "Kdga", message: "Hello", date: nil, isOnline: true, hasUnreadMessages: nil),
            ConversationListCellModel(name: "Sanders Gasg", message: "Hello", date: nil, isOnline: false, hasUnreadMessages: nil),
            ConversationListCellModel(name: "Utodsg Fgdsga", message: "Hello", date: nil, isOnline: false, hasUnreadMessages: nil),
            ConversationListCellModel(name: "Zhora", message: "Hello", date: nil, isOnline: false, hasUnreadMessages: nil),
            ConversationListCellModel(name: "Fafe Fhe", message: "Hello", date: nil, isOnline: false, hasUnreadMessages: nil),
            ConversationListCellModel(name: "Geqrq", message: "Hello", date: nil, isOnline: true, hasUnreadMessages: nil),
            ConversationListCellModel(name: "Tewqg Wsf", message: "Hello", date: nil, isOnline: false, hasUnreadMessages: nil),
            ConversationListCellModel(name: "Iogw Ig", message: "Hello", date: nil, isOnline: true, hasUnreadMessages: nil)
        ]
        view?.showMain()
    }
    
    func didTappedProfile() {
        guard let profile = profile else { return }
        router?.showProfile(profile: profile)
    }
}
