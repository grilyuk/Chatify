import UIKit

protocol ProfilePresenterProtocol: AnyObject {
    func viewReady()
    func dataUploaded()
    func updateProfile(profile: ProfileModel)
    var profile: ProfileModel? { get set }
}

class ProfilePresenter {
    
    // MARK: - Properties
    
    weak var view: ProfileViewProtocol?
    let interactor: ProfileInteractorProtocol
    var profile: ProfileModel?

    // MARK: - Initialization
    
    init(interactor: ProfileInteractorProtocol) {
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
}
