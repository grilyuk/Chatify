//
//  MainPresenter.swift
//  ChatTFS
//
//  Created by Григорий Данилюк on 26.02.2023.
//

import UIKit

protocol ConvListPresenterProtocol: AnyObject {
    var profile: ProfileModel? { get set }
    func viewReady()
    func dataUploaded()
    func didTappedProfile()
    func didTappedConversation(for conversation: ConversationListCellModel)
}

class ConvListPresenter {
    weak var view: ConvListViewProtocol?
    let router: RouterProtocol?
    let interactor: ConvListInteractorProtocol
    var profile: ProfileModel?
    
    init(router: RouterProtocol, interactor: ConvListInteractorProtocol) {
        self.router = router
        self.interactor = interactor
    }
}

extension ConvListPresenter: ConvListPresenterProtocol {
    func viewReady() {
        interactor.loadData()
    }
    
    func dataUploaded() {
        view?.users = [
            ConversationListCellModel(name: "Charis Clay",
                                      message: "I think Houdini did something like this once! Why, if I recall correctly, he was out of the hospital",
                                      date: Date(timeIntervalSinceNow: -100000),
                                      isOnline: true,
                                      hasUnreadMessages: nil),
            ConversationListCellModel(name: "Lacey Finch",
                                      message: nil,
                                      date: nil,
                                      isOnline: false,
                                      hasUnreadMessages: nil),
            ConversationListCellModel(name: "Norma Carver",
                                      message: nil,
                                      date: nil,
                                      isOnline: true,
                                      hasUnreadMessages: nil),
            ConversationListCellModel(name: "Dawson Suarez",
                                      message: "Привет",
                                      date: Date(timeIntervalSinceNow: -54252),
                                      isOnline: false,
                                      hasUnreadMessages: nil),
            ConversationListCellModel(name: "Aminah Burch",
                                      message: "How are you?",
                                      date: Date(timeIntervalSinceNow: -4235),
                                      isOnline: false,
                                      hasUnreadMessages: nil),
            ConversationListCellModel(name: "Rodney Sharp",
                                      message: "Go to shop",
                                      date: Date(timeIntervalSinceNow: -3242),
                                      isOnline: true,
                                      hasUnreadMessages: nil),
            ConversationListCellModel(name: "Erin Duke",
                                      message: nil,
                                      date: nil,
                                      isOnline: false,
                                      hasUnreadMessages: nil),
            ConversationListCellModel(name: "Mehmet Matthams",
                                      message: nil,
                                      date: nil,
                                      isOnline: false,
                                      hasUnreadMessages: nil),
            ConversationListCellModel(name: "Malik Rios",
                                      message: "Я с тобой не разговариваю...",
                                      date: Date(timeIntervalSince1970: 0),
                                      isOnline: true,
                                      hasUnreadMessages: nil),
            ConversationListCellModel(name: "Samantha Erickson",
                                      message: "Ладно",
                                      date: Date(timeIntervalSinceNow: -124151513),
                                      isOnline: true,
                                      hasUnreadMessages: nil),
            ConversationListCellModel(name: "Sid Terry",
                                      message: "Hello",
                                      date: Date(timeIntervalSinceReferenceDate: 4525346),
                                      isOnline: true,
                                      hasUnreadMessages: nil),
            ConversationListCellModel(name: "Lochlan Alexander",
                                      message: nil,
                                      date: nil,
                                      isOnline: false,
                                      hasUnreadMessages: nil),
            ConversationListCellModel(name: "Ishaan Matthews",
                                      message: "Hello",
                                      date: Date(timeIntervalSinceNow: -5325),
                                      isOnline: true,
                                      hasUnreadMessages: nil),
            ConversationListCellModel(name: "Jazmin Clayton",
                                      message: "Я в своём познании настолько преисполнился, что как будто бы уже 100 триллионов миллиардов лет проживаю",
                                      date: Date(timeIntervalSinceReferenceDate: 1352533),
                                      isOnline: true,
                                      hasUnreadMessages: nil),
            ConversationListCellModel(name: "Hamish Barker",
                                      message: "Hello",
                                      date: Date(),
                                      isOnline: false,
                                      hasUnreadMessages: nil),
            ConversationListCellModel(name: "Kezia Finley",
                                      message: "Прив че дел??",
                                      date: Date(timeIntervalSinceNow: -9932),
                                      isOnline: false,
                                      hasUnreadMessages: nil),
            ConversationListCellModel(name: "Sylvia Cooper",
                                      message: "Предлагаем работу 300кк/нс нужно всего лишь быть",
                                      date: Date(timeIntervalSinceNow: -35551),
                                      isOnline: false,
                                      hasUnreadMessages: nil),
            ConversationListCellModel(name: "Erica Tate",
                                      message: nil,
                                      date: nil,
                                      isOnline: false,
                                      hasUnreadMessages: nil),
            ConversationListCellModel(name: "Liana Fitzgerald",
                                      message: nil,
                                      date: nil,
                                      isOnline: true,
                                      hasUnreadMessages: nil),
            ConversationListCellModel(name: "Aiza Fischer",
                                      message: nil,
                                      date: nil,
                                      isOnline: false,
                                      hasUnreadMessages: nil)
        ]
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
