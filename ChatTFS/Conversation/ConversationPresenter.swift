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
    let conversation: ConversationListCellModel?
    
    init(router: RouterProtocol, interactor: ConversationInteractorProtocol, conversation: ConversationListCellModel) {
        self.router = router
        self.interactor = interactor
        self.conversation = conversation
    }
}

extension ConversationPresenter: ConversationPresenterProtocol {
    func viewReady() {
        interactor.loadData()
    }
    
    func dataUploaded() {
        view?.showConversation()

        guard let view = view as? ConversationViewController else { return }
        view.historyChat = [
            MessageCellModel(text: "я в своем познании настолько преисполнился, что перешагнул через бытие и познание, - в том числе, и через бытие, и познание. А вот как, каким образом я это сделал - это другой вопрос. Но Вы, совершенно верно, правы - я ничего не знаю о том, как я это это сделал.", date: Date(timeIntervalSinceNow: 0), myMessage: true),
            MessageCellModel(text: "И это - самое главное. Я - не на уровне знания, а на уровне бытия, на уровне истины, на уровне Бога.", date: Date(timeIntervalSinceNow: 0), myMessage: false),
            MessageCellModel(text: "ОК", date: Date(timeIntervalSinceNow: 0), myMessage: true),
            MessageCellModel(text: "Для меня это принципиально - именно в этом месте я остановился.", date: Date(timeIntervalSinceNow: 0), myMessage: false),
            MessageCellModel(text: "Не до этого места, не после этого места - а именно здесь.", date: Date(timeIntervalSinceNow: -412), myMessage: true),
            MessageCellModel(text: "Не до этого места, не после этого места - а именно здесь.", date: Date(timeIntervalSinceNow: -2515), myMessage: true),
            MessageCellModel(text: "Поэтому я и говорю - что это то, что мне ближе всего.", date: Date(timeIntervalSinceNow: -5151), myMessage: false),
            MessageCellModel(text: "- Привет! - Привет! Что это у тебя? - Да вот, несу разные вещи. - Чем же они несуразные? - Сам ты несуразный! Разные вещи я несу, разные! Вот, например, несу мел. - Что не сумел?..", date: Date(timeIntervalSinceNow: -412), myMessage: false),
            MessageCellModel(text: "Первая брачная ночь, муж морально готовит жену: - Дорогая, сейчас будет немного больно, а потом приятно... Через час новобрачная интересуется: - А когда же будет больно? - А вот сейчас кончу и по морде дам.", date: Date(timeIntervalSinceNow: -5151), myMessage: true),
            MessageCellModel(text: "Похоже, сегодня фундаментальная наука интересует только исламских фундаменталистов...", date: Date(timeIntervalSinceNow: -412), myMessage: false),
            MessageCellModel(text: "Не смешно", date: Date(timeIntervalSinceNow: 0), myMessage: true),
            MessageCellModel(text: "Ok", date: Date(timeIntervalSinceNow: -52315), myMessage: true),
            MessageCellModel(text: "Тестим тестим тестим \nТестим ттим тестим тестим", date: Date(timeIntervalSinceNow: -412), myMessage: true),
            MessageCellModel(text: "Тестим тестим тестим \nТестим тестим тестим\nТестим тестим тестим", date: Date(timeIntervalSinceNow: -412), myMessage: true),
            MessageCellModel(text: "На чемпионате Европы по футболу в Португалии зафиксирован случай группового изнасилования. В группе А поимели сборную России.", date: Date(timeIntervalSinceNow: -412), myMessage: true),
            MessageCellModel(text: "Hello world", date: Date(timeIntervalSinceNow: -412), myMessage: false),
            MessageCellModel(text: "Чтобы дольше жить, надо чаще умирать со смеху", date: Date(timeIntervalSinceNow: -5452552), myMessage: true),
            MessageCellModel(text: "Как много слов о любви уже не сказано! А сколько еще предстоит не сказать!", date: Date(timeIntervalSinceNow: -412), myMessage: true),
            MessageCellModel(text: "Тестим тестим тестим \nТестим ттим тестим тестим", date: Date(timeIntervalSinceNow: 0), myMessage: false),
            MessageCellModel(text: "Тестим тестим тестим \nТестим ттим тестим тестим", date: Date(timeIntervalSinceNow: 215125), myMessage: false)
        ]
        view.userName = conversation?.name ?? ""
    }
}
