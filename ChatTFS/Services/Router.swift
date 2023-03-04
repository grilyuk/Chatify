//
//  Router.swift
//  ChatTFS
//
//  Created by Григорий Данилюк on 04.03.2023.
//

import Foundation
import UIKit

protocol MainRouterProtocol: AnyObject {
    func showProfile(profile: ProfileModel)
}

protocol ProfileRouterProtocol: AnyObject {
    func editProfile()
}

class Router {
    weak var view: UIViewController?
}

//MARK: Router + MainRouterProtocol
extension Router: MainRouterProtocol {
    func showProfile(profile: ProfileModel) {
        let vc = ModuleBuilder.buildProfile(profile: profile)
        view?.present(vc, animated: true)
    }
}

//MARK: Router + ProfileRouterProtocol
extension Router: ProfileRouterProtocol {
    func editProfile() {
        //temporary empty
    }
}
