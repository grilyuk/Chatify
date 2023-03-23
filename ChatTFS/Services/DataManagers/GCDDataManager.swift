import UIKit

class GCDDataManager: DataManager {
    
    //MARK: - Properties
    private var queue = DispatchQueue.global(qos: .utility)
    private var work: DispatchWorkItem?

    //MARK: - Methods
    func asyncWriteData(profileData: ProfileModel, completion: @escaping (Bool) -> Void) {
        queue.async { [weak self] in
            guard let self = self else { return }
            let isSuccess = self.writeData(profileData: profileData)
            DispatchQueue.main.async {
                switch isSuccess {
                case true:
                    completion(isSuccess)
                case false:
                    completion(isSuccess)
                }
            }
        }
    }
    
    func asyncReadData(completion: @escaping (ProfileModel) -> Void) {
        queue.async { [weak self] in
            guard let self = self else { return }
            let profile = self.readData()
            DispatchQueue.main.async {
                completion(profile)
            }
        }
    }
}
