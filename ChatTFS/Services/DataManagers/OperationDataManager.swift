import UIKit

class SaveProfileOperation: Operation {
    private var profile: ProfileModel?
    private var dataManager: DataManagerProtocol?
    var isSuccess = false
    
    init(profile: ProfileModel?, dataManager: DataManagerProtocol?) {
        self.profile = profile
        self.dataManager = dataManager
    }
    
    override func main() {
        guard let dataManager = dataManager,
              let profile = profile else { return }
        switch dataManager.writeData(profileData: profile) {
        case true: isSuccess = true
        case false: isSuccess = false
        }
    }
}

class ReadProfileOperation: Operation {
    private var dataManager: DataManagerProtocol?
    var profile: ProfileModel?
    
    init(dataManager: DataManagerProtocol) {
        self.dataManager = dataManager
    }
    
    override func main() {
        guard let dataManager = dataManager else { return }
        profile = dataManager.readData()
    }
}
