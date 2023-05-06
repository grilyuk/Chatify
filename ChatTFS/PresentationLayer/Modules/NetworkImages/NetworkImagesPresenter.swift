import UIKit

protocol NetworkImagesPresenterProtocol: AnyObject {
    var uploadedImages: [NetworkImageModel] { get set }
    func viewReady()
    func dataUploaded()
    func loadImage(for uuid: UUID, url: String)
}

class NetworkImagesPresenter: NetworkImagesPresenterProtocol {
    
    // MARK: - Initialization
    
    init(interactor: NetworkImagesInteractorProtocol) {
        self.interactor = interactor
    }
    
    // MARK: - Public properties
    
    weak var view: NetworkImagesViewProtocol?
    var uploadedImages: [NetworkImageModel] = []
    var handler: (([NetworkImageModel]) -> Void)?
    
    // MARK: - Private properties
    
    private var interactor: NetworkImagesInteractorProtocol
    
    // MARK: - Public methods
    
    func viewReady() {
        interactor.loadData()
    }
    
    func dataUploaded() {
        
        handler = { [weak self] cellModels in
            self?.view?.images = cellModels
            self?.view?.showNetworkImages()
        }
        
        handler?(uploadedImages)
    }
    
    func loadImage(for uuid: UUID, url: String) {
        guard let index = view?.images.firstIndex(where: { $0.uuid == uuid }) else {
            return
        }
        
        interactor.downloadImage(link: url) { [weak self] result in
            switch result {
            case .success(let image):
                self?.view?.images[index].image = image
                self?.view?.images[index].isAvailable = true
            case .failure(let error):
                print(error)
            }
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.view?.updateImageInCell(uuid: uuid)
        }
    }
}
