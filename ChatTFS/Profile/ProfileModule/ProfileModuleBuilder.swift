//
//  ProfileModuleBuilder.swift
//  ChatTFS
//
//  Created by Григорий Данилюк on 26.02.2023.
//

import UIKit

class ProfileModuleBuilder {
    func profileBuild(data: ProfileModel) -> ProfileViewController {
        let router = ProfileRouter()
        let interactor = ProfileInteractor(profile: data)
        let presenter = ProfilePresenter(router: router, interactor: interactor)
        let view = ProfileViewController()
        view.presenter = presenter
        interactor.presenter = presenter
        presenter.view = view
        router.view = view
        return view
    }
}
