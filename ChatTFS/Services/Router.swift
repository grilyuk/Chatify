//
//  Router.swift
//  ChatTFS
//
//  Created by Григорий Данилюк on 04.03.2023.
//

import Foundation
import UIKit

protocol RouterMain: AnyObject {
    var navigationController: UINavigationController? {get set}
    var moduleBuilder: ModuleBuilderProtocol? {get set}
}

protocol RouterProtocol: RouterMain {
    func initialViewController()
    func showProfile(profile: ProfileModel)
}

class Router: RouterProtocol {
    
    var navigationController: UINavigationController?
    var moduleBuilder: ModuleBuilderProtocol?
    
    init(navigationController: UINavigationController, moduleBuilder: ModuleBuilderProtocol) {
        self.navigationController = navigationController
        self.moduleBuilder = moduleBuilder
    }
    
    func initialViewController() {
        if let navigationController = navigationController {
            guard let mainViewProtocol = moduleBuilder?.buildMain(router: self) else { return }
            navigationController.viewControllers = [mainViewProtocol]
        }
    }
    
    func showProfile(profile: ProfileModel) {
        if let navigationController = navigationController {
            guard let profileViewProtocol = moduleBuilder?.buildProfile(router: self, profile: profile) else { return }
            navigationController.present(profileViewProtocol, animated: true)
            
        }
    }
}
