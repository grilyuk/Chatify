//
//  ModuleBuilder.swift
//  ChatTFS
//
//  Created by Григорий Данилюк on 04.03.2023.
//

import Foundation

protocol ModuleBuilderProtocol: AnyObject {
    func buildMain() -> MainViewController
    func buildProfile(profile: ProfileModel) -> ProfileViewController
}

class ModuleBuilder: ModuleBuilderProtocol {
    func buildMain() -> MainViewController {
        let view = MainViewController()
        let router = Router()
        let interactor = MainInteractor()
        let presenter = MainPresenter(router: router, interactor: interactor)
        view.presenter = presenter
        interactor.presenter = presenter
        router.view = view
        return view
    }
    
    func buildProfile(profile: ProfileModel) -> ProfileViewController {
        return ProfileViewController()
    }
}
