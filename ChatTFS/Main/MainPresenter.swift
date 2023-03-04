//
//  MainPresenter.swift
//  ChatTFS
//
//  Created by Григорий Данилюк on 26.02.2023.
//

import UIKit

protocol MainPresenterProtocol: AnyObject {
    func viewDidLoaded()
    func dataDidLoaded()
    func didTappedProfile()
}

class MainPresenter {
    weak var view: MainViewProtocol?
    let router: MainRouterProtocol
    let interactor: MainInteractorProtocol
    
    init(router: MainRouterProtocol, interactor: MainInteractorProtocol) {
        self.router = router
        self.interactor = interactor
    }
}

extension MainPresenter: MainPresenterProtocol {
    func viewDidLoaded() {
        interactor.loadData()
    }
    
    func dataDidLoaded() {
        view?.showMain()
    }
    
    func didTappedProfile() {
        guard let profile = interactor.profile else { return }
        router.showProfile(profile: profile)
    }
}
