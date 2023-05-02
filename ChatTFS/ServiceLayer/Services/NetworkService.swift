import Foundation
import UIKit

protocol NetworkServiceProtocol: AnyObject {
    func sendRequest<T: Decodable>(_ request: URLRequest, completion: @escaping (Result<T, Error>) -> Void)
    func sendRequestForImage(_ request: URLRequest, completion: @escaping (Result<UIImage, Error>) -> Void)
}

class NetworkService: NetworkServiceProtocol {
    
    // MARK: - Initialization
    
    init() {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.urlCache = URLCache(memoryCapacity: 50 * 1024 * 1024,
                                          diskCapacity: 100 * 1024 * 1024,
                                          diskPath: "networking")
//        self.session = URLSession(configuration: configuration)
        self.session = .shared
    }
    
    // MARK: - Private properties
    
    private var session: URLSession
    
    // MARK: - Public methods
    
    func sendRequest<T: Decodable>(_ request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) {
        session.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(CustomError(description: "data error")))
                return
            }
            
            do {
                let model = try JSONDecoder().decode(T.self, from: data)
                completion(.success(model))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func sendRequestForImage(_ request: URLRequest, completion: @escaping (Result<UIImage, Error>) -> Void) {
        session.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(CustomError(description: "data error")))
                return
            }
            
            if let image = UIImage(data: data) {
                completion(.success(image))
            } else {
                if let error = error {
                    completion(.failure(error))
                }
            }

        }.resume()
    }
}
