//
//  MainRouter.swift
//  ChatTFS
//
//  Created by Григорий Данилюк on 26.02.2023.
//

import UIKit

protocol MainRouterProtocol: AnyObject {
    func showProfile(profile: ProfileModel)
}

class MainRouter {
    weak var view: MainViewController?
}

extension MainRouter: MainRouterProtocol {
    func showProfile(profile: ProfileModel) {
        let vc = ProfileModuleBuilder().profileBuild(data: profile)
        view?.present(vc, animated: true)
    }
}
