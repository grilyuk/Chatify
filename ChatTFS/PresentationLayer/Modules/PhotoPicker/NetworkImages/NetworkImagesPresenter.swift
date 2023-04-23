import UIKit

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
    var uploadedImages: [NetworkImageModel] = []
    
    // MARK: - Private properties
    
    private var interactor: NetworkImagesInteractorProtocol
    
    // MARK: - Public methods
    
    func viewReady() {
        interactor.loadData()
    }
    
    func dataUploaded() {
        uploadedImages = [NetworkImageModel(image: UIImage(systemName: "gear") ?? UIImage(), isAvailable: true),
                          NetworkImageModel(image: UIImage(systemName: "heart") ?? UIImage(), isAvailable: false)]
        view?.showNetworkImages(images: uploadedImages)
    }
}
