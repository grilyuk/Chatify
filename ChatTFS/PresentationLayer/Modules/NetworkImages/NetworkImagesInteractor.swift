import Foundation
import UIKit

protocol NetworkImagesInteractorProtocol: AnyObject {
    func loadData()
    func downloadImage(link: String, completion: @escaping (Result<UIImage, Error>) -> Void)
}

class NetworkImagesInteractor: NetworkImagesInteractorProtocol {
    
    init(imageLoader: ImageLoaderServiceProtocol) {
        self.imageLoader = imageLoader
    }
    
    // MARK: - Public properties
    
    weak var presenter: NetworkImagesPresenterProtocol?
    
    // MARK: - Private properties
    
    private var handler: (([NetworkImageModel]) -> Void)?
    private var imageLoader: ImageLoaderServiceProtocol
    
    // MARK: - Public methods
    
    func loadData() {

        handler = { [weak self] cellModels in
            self?.presenter?.uploadedImages = cellModels
            self?.presenter?.dataUploaded()
        }
        
        imageLoader.getLinks { [weak self] result in
            switch result {
            case .success(let links):
                let cellModels = links.map { link in
                    return NetworkImageModel(isAvailable: false,
                                             link: link.url)
                }
                DispatchQueue.main.async {
                    self?.handler?(cellModels)
                }
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
    }
    
    func downloadImage(link: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
//        sleep(1)
        imageLoader.downloadImage(with: link, completion: completion)
    }
}
