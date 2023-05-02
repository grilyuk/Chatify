import Foundation
import UIKit

protocol ImageLoaderServiceProtocol: AnyObject {
    func getLinks(completion: @escaping (Result<[ImageLinkModel], Error>) -> Void)
    func downloadImage(with url: String, completion: @escaping (Result<UIImage, Error>) -> Void)
}

class ImageLoaderService: ImageLoaderServiceProtocol {
    
    // MARK: - Initialization
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    // MARK: - Private properties
    
    private let mockJsonLink: String = "https://run.mocky.io/v3/8317ecaa-ac7d-4b6f-8d27-86fe6ab57596"
    private var networkService: NetworkServiceProtocol
    
    // MARK: - Public methods
    
    func getLinks(completion: @escaping (Result<[ImageLinkModel], Error>) -> Void) {
        
        guard let url = URL(string: mockJsonLink) else {
            return
        }
        
        let request = URLRequest(url: url)
        
        networkService.sendRequest(request, completion: completion)
    }
    
    func downloadImage(with url: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        guard let url = URL(string: url) else {
            return
        }
        
        let request = URLRequest(url: url)
        
        networkService.sendRequestForImage(request, completion: completion)
    }
}
