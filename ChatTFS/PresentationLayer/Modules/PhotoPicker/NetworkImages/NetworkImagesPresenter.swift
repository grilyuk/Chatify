import Foundation

protocol NetworkImagesPresenterProtocol: AnyObject {
    func viewReady()
    func dataUploaded()
}

class NetworkImagesPresenter: NetworkImagesPresenterProtocol {
    
    // MARK: - Initialization
    
    init(interactor: NetworkImagesInteractorProtocol) {
        self.interactor = interactor
    }
    
    // MARK: - Public properties
    
    weak var view: NetworkImagesViewProtocol?
    
    // MARK: - Private properties
    
    private var interactor: NetworkImagesInteractorProtocol
    
    // MARK: - Public methods
    
    func viewReady() {
        interactor.loadData()
    }
    
    func dataUploaded() {
        view?.showNetworkImages()
    }
}
