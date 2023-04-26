import Foundation
import UIKit

protocol NetworkServiceProtocol: AnyObject {
    func sendRequest<T: Decodable>(_ request: URLRequest, completion: @escaping (Result<T, Error>) -> Void)
}

class NetworkService: NetworkServiceProtocol {
    
    // MARK: - Initialization
    
    init() {}
    
    // MARK: - Private properties
    
    private let session = URLSession.shared
    
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
}
