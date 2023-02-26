//
//  ProfileRouter.swift
//  ChatTFS
//
//  Created by Григорий Данилюк on 26.02.2023.
//

import UIKit

protocol ProfileRouterProtocol: AnyObject {
    
}

class ProfileRouter {
    weak var view: ProfileViewController?
}

//MARK: ProfileRouter + ProfileRouterProtocol
extension ProfileRouter: ProfileRouterProtocol {

}
