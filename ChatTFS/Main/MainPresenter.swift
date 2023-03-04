//
//  MainPresenter.swift
//  ChatTFS
//
//  Created by Григорий Данилюк on 26.02.2023.
//

import UIKit

protocol MainPresenterProtocol: AnyObject {
    var profile: ProfileModel? { get set }
    func viewReady()
    func dataUploaded()
    func didTappedProfile()
}

class MainPresenter {
    weak var view: MainViewProtocol?
    let router: MainRouterProtocol?
    let interactor: MainInteractorProtocol
    var profile: ProfileModel?
    
    init(router: MainRouterProtocol, interactor: MainInteractorProtocol) {
        self.router = router
        self.interactor = interactor
    }
}

extension MainPresenter: MainPresenterProtocol {
    func viewReady() {
        interactor.loadData()
    }
    
    func dataUploaded() {
        view?.showMain()
        profile = ProfileModel(profileImage: nil,
                                          fullName: "Grigoriy Danilyuk",
                                          statusText: "Almost iOS Developer \nSaint-Petersburg, Russia")
    }
    
    func didTappedProfile() {
        guard let profile = profile else { return }
        router?.showProfile(profile: profile)
    }
}
