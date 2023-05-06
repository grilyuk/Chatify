import UIKit

protocol ProfilePresenterProtocol: AnyObject {
    func viewReady()
    func dataUploaded()
    func updateProfile(profile: ProfileModel)
    func showNetworkImages(navigationController: UINavigationController, vc: UIViewController)
    var profile: ProfileModel? { get set }
    var router: RouterProtocol { get }
}

class ProfilePresenter {
    
    // MARK: - Properties
    
    weak var view: ProfileViewProtocol?
    let router: RouterProtocol
    let interactor: ProfileInteractorProtocol
    var profile: ProfileModel?

    // MARK: - Initialization
    
    init(interactor: ProfileInteractorProtocol, router: RouterProtocol) {
        self.router = router
        self.interactor = interactor
    }
}

// MARK: - ProfilePresenter + ProfilePresenterProtocol

extension ProfilePresenter: ProfilePresenterProtocol {
    func dataUploaded() {
        view?.showProfile()
    }
    
    func viewReady() {
        interactor.loadData()
    }
    
    func updateProfile(profile: ProfileModel) {
        interactor.updateData(profile: profile)
    }
    
    func showNetworkImages(navigationController: UINavigationController, vc: UIViewController) {
        router.showNetworkImages(navigationController: navigationController, vc: vc)
    }
}
