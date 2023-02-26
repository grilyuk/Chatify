//
//  ProfilePresenter.swift
//  ChatTFS
//
//  Created by Григорий Данилюк on 26.02.2023.
//

import UIKit

protocol ProfilePresenterProtocol: AnyObject {
    func viewDidLoaded()
    func didLoad(data: ProfileModel)
}

class ProfilePresenter {
    weak var view: ProfileViewProtocol?
    let router: ProfileRouterProtocol
    let interactor: ProfileInteractorProtocol

    init(router: ProfileRouterProtocol, interactor: ProfileInteractorProtocol) {
        self.router = router
        self.interactor = interactor
    }
}

//MARK: ProfilePresenter + ProfilePresenterProtocol
extension ProfilePresenter: ProfilePresenterProtocol {
    func didLoad(data: ProfileModel) {
        view?.showProfile(profile: data)
    }

    func viewDidLoaded() {
        interactor.loadData()
    }
}
