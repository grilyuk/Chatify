//
//  ModuleBuilder.swift
//  ChatTFS
//
//  Created by Григорий Данилюк on 04.03.2023.
//

import Foundation

protocol ModuleBuilderProtocol: AnyObject {
    func buildMain(router: RouterProtocol) -> MainViewController
    func buildProfile(router: RouterProtocol, profile: ProfileModel) -> ProfileViewController
}

class ModuleBuilder: ModuleBuilderProtocol {
    func buildMain(router: RouterProtocol) -> MainViewController {
        let view = MainViewController()
        let interactor = MainInteractor()
        let presenter = MainPresenter(router: router, interactor: interactor)
        view.presenter = presenter
        interactor.presenter = presenter
        presenter.view = view
        return view
    }

    func buildProfile(router: RouterProtocol, profile: ProfileModel) -> ProfileViewController {
        let view = ProfileViewController()
        let interactor = ProfileInteractor()
        let presenter = ProfilePresenter(router: router, interactor: interactor, profile: profile)
        view.presenter = presenter
        interactor.presenter = presenter
        presenter.view = view
        return view
    }
}
