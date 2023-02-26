//
//  MainModuleBuilder.swift
//  ChatTFS
//
//  Created by Григорий Данилюк on 26.02.2023.
//

import UIKit

class MainModuleBuilder {
    func mainBuild() -> MainViewController {
        let router = MainRouter()
        let interactor = MainInteractor()
        let presenter = MainPresenter(router: router, interactor: interactor)
        let view = MainViewController()
        view.presenter = presenter
        interactor.presenter = presenter
        presenter.view = view
        router.view = view
        return view
    }
}
