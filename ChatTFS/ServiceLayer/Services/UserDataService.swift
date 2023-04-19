import Foundation
import Combine

protocol UserDataServiceProtocol: AnyObject {
//    var currentProfile: CurrentValueSubject<ProfileModel, Never> { get set }
    var profileModel: ProfileModel { get set }
    
}

final class UserDataService {
    
    // MARK: - Initialization
    
    init(dataManager: UserDataProtocol) {
        self.dataManager = dataManager
    }
    
    // MARK: - Public properties
    
    var dataManager: UserDataProtocol
    
    var profileModel = ProfileModel(fullName: "",
                                 statusText: "",
                                 profileImageData: Data())
    
    // MARK: - Public methods
    
    func loadUser() {
//        dataManager.getUserModel
    }
    
}
