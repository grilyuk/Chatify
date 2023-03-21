import UIKit

class GCDDataManager: DataManager {
    
    //MARK: - Properties
    let queue = DispatchQueue.global(qos: .utility)
    
    let work = DispatchWorkItem {
        
    }
    
    func asyncWriteData(profileData: ProfileModel, completion: @escaping (Result<Bool, Error>) -> Void) {
        queue.async { [weak self] in
            guard let self = self else { return }
            if self.writeData(profileData: profileData) {
                completion(.success(true))
            } else {
                completion(.success(false))
            }
        }
    }
}
