import UIKit

protocol ProfilePresenterProtocol: AnyObject {
    func viewReady()
    func dataUploaded()
    func updateProfile(profile: ProfileModel)
    var profile: ProfileModel? { get set }
}

class ProfilePresenter {
    weak var view: ProfileViewProtocol?
    let router: RouterProtocol
    let interactor: ProfileInteractorProtocol
    var profile: ProfileModel?

    init(router: RouterProtocol, interactor: ProfileInteractorProtocol) {
        self.router = router
        self.interactor = interactor
    }
}

//MARK: ProfilePresenter + ProfilePresenterProtocol
extension ProfilePresenter: ProfilePresenterProtocol {
    func dataUploaded() {
        view?.showProfile()
    }
    
    func updateProfile(profile: ProfileModel) {
        interactor.pushData(profile: profile)
    }

    func viewReady() {
        interactor.loadData()
    }
}
