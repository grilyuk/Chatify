import Foundation
import UIKit

protocol ImageLoaderServiceProtocol: AnyObject {
    func getLinks(completion: @escaping (Result<[ImageLinkModel], Error>) -> Void)
    func downloadImage(with url: String) -> UIImage
}

class ImageLoaderService: ImageLoaderServiceProtocol {
    
    // MARK: - Initialization
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    // MARK: - Private properties
    
    private let mockJsonLink: String = "https://run.mocky.io/v3/bd6a352b-7d31-4e1f-9ebd-9fd26a02b100"
    private var networkService: NetworkServiceProtocol
    
    // MARK: - Public methods
    
    func getLinks(completion: @escaping (Result<[ImageLinkModel], Error>) -> Void) {
        
        guard let url = URL(string: mockJsonLink) else {
            return
        }
        
        let request = URLRequest(url: url)
        
        networkService.sendRequest(request, completion: completion)
    }
    
    func downloadImage(with url: String) -> UIImage {
        guard let link = URL(string: url),
              let data = try? Data(contentsOf: link),
              let image = UIImage(data: data)
        else {
            return UIImage(systemName: "questionmark.app") ?? UIImage()
        }
        return image
    }
}
