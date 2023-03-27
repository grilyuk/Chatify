import UIKit

protocol ProfileInteractorProtocol: AnyObject {
    var dataManager: DataManagerProtocol? { get set }
    func loadData()
}

class ProfileInteractor: ProfileInteractorProtocol {
    
    init(dataManager: DataManagerProtocol) {
        self.dataManager = dataManager
    }
    weak var dataManager: DataManagerProtocol?
    weak var presenter: ProfilePresenterProtocol?
    
    private var handler: ((ProfileModel) -> Void)?

    func loadData() {
        
        handler = { [weak self] profile in
            self?.presenter?.profile = profile
            self?.presenter?.dataUploaded()
        }
        
        guard let currentProfile = dataManager?.currentProfile else { return }
        handler?(currentProfile)
    }
}
