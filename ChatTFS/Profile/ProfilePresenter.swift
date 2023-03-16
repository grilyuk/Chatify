//
//  ProfilePresenter.swift
//  ChatTFS
//
//  Created by Григорий Данилюк on 26.02.2023.
//

import UIKit

protocol ProfilePresenterProtocol: AnyObject {
    func viewReady()
    func dataUploaded()
    var profile: ProfileModel { get set }
}

class ProfilePresenter {
    weak var view: ProfileViewProtocol?
    let router: RouterProtocol
    let interactor: ProfileInteractorProtocol
    var profile: ProfileModel

    init(router: RouterProtocol, interactor: ProfileInteractorProtocol, profile: ProfileModel) {
        self.router = router
        self.interactor = interactor
        self.profile = profile
    }
}

//MARK: ProfilePresenter + ProfilePresenterProtocol
extension ProfilePresenter: ProfilePresenterProtocol {
    func dataUploaded() {
        view?.showProfile(profile: profile)
    }

    func viewReady() {
        interactor.loadData()
    }
}
