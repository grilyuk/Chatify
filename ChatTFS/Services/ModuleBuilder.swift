//
//  ModuleBuilder.swift
//  ChatTFS
//
//  Created by Григорий Данилюк on 04.03.2023.
//

import Foundation

protocol ModuleBuilderProtocol: AnyObject {
    func buildConvList(router: RouterProtocol) -> ConvListViewController
    func buildProfile(router: RouterProtocol, profile: ProfileModel) -> ProfileViewController
    func buildConversation(router: RouterProtocol, conversation: IndexPath) -> ConversationViewController
}

class ModuleBuilder: ModuleBuilderProtocol {
    func buildConvList(router: RouterProtocol) -> ConvListViewController {
        let interactor = ConvListInteractor()
        let presenter = ConvListPresenter(router: router, interactor: interactor)
        let view = ConvListViewController()
        view.presenter = presenter
        interactor.presenter = presenter
        presenter.view = view
        return view
    }

    func buildProfile(router: RouterProtocol, profile: ProfileModel) -> ProfileViewController {
        let interactor = ProfileInteractor()
        let view = ProfileViewController()
        let presenter = ProfilePresenter(router: router, interactor: interactor, profile: profile)
        view.presenter = presenter
        interactor.presenter = presenter
        presenter.view = view
        return view
    }
    
    func buildConversation(router: RouterProtocol, conversation: IndexPath) -> ConversationViewController {
        let interactor = ConversationInteractor()
        let presenter = ConversationPresenter(router: router, interactor: interactor, conversation: conversation)
        let view = ConversationViewController()
        view.presenter = presenter
        interactor.presenter = presenter
        presenter.view = view
        return view
    }
}
