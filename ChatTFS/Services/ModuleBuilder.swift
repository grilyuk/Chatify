//
//  ModuleBuilder.swift
//  ChatTFS
//
//  Created by Григорий Данилюк on 04.03.2023.
//

import Foundation

protocol ModuleBuilderProtocol: AnyObject {
    static func buildMain() -> MainViewController
    static func buildProfile(profile: ProfileModel) -> ProfileViewController
}

class ModuleBuilder: ModuleBuilderProtocol {
    static func buildMain() -> MainViewController {
        let view = MainViewController()
        let router = Router()
        let interactor = MainInteractor()
        let presenter = MainPresenter(router: router, interactor: interactor)
        presenter.view = view
        view.presenter = presenter
        interactor.presenter = presenter
        router.view = view
        return view
    }

    static func buildProfile(profile: ProfileModel) -> ProfileViewController {
        let interactor = ProfileInteractor()
        let view = ProfileViewController()
        let router = Router()
        let presenter = ProfilePresenter(router: router, interactor: interactor, profile: profile)
        presenter.view = view
        view.presenter = presenter
        interactor.presenter = presenter
        router.view = view
        return view
    }
}
