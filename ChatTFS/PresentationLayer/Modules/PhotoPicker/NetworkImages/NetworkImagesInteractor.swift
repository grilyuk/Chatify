import Foundation

protocol NetworkImagesInteractorProtocol: AnyObject {
    func loadData()
}

class NetworkImagesInteractor: NetworkImagesInteractorProtocol {
    
    weak var presenter: NetworkImagesPresenterProtocol?
    
    func loadData() {
        presenter?.dataUploaded()
    }
}
