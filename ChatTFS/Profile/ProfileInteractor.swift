import UIKit

protocol ProfileInteractorProtocol: AnyObject {
    func loadData()
}

class ProfileInteractor: ProfileInteractorProtocol {
    weak var presenter: ProfilePresenterProtocol?

    func loadData() {
        presenter?.dataUploaded()
    }
}
