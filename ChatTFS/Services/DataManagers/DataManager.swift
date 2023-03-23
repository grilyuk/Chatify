import UIKit

protocol DataManagerObserver: AnyObject {
    var subscribers: [DataManagerSubscriber] { get set }
    func addSubscriber(subscriber: DataManagerSubscriber)
}

protocol DataManagerSubscriber: AnyObject {
    func updateProfile(profile: ProfileModel)
}

protocol DataManagerProtocol: AnyObject {
    var currentProfile: ProfileModel { get set }
    func checkPath() -> Bool
    func writeData(profileData: ProfileModel) -> Bool
    func readData() -> ProfileModel
}

class DataManager: DataManagerProtocol {
    
    //MARK: - Properties
    var subscribers: [DataManagerSubscriber] = []
    lazy var defaultProfile = ProfileModel(fullName: nil, statusText: nil, profileImageData: nil)
    var currentProfile: ProfileModel {
        get { return readData() }
        set { subscribers.forEach {$0.updateProfile(profile: newValue) } }
    }

    //MARK: - Methods
    func checkPath() -> Bool {
        guard let filePath = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("profileData.json").path else { return false }
        
        if FileManager.default.fileExists(atPath: filePath) {
            print(filePath)
            return true
        } else {
            return false
        }
    }
    
    func writeData(profileData: ProfileModel) -> Bool {
        sleep(5)
        var profileToJSON: Data?
        var result: Bool = false
        do {
            profileToJSON = try JSONEncoder().encode(profileData)
        } catch {
            print("Error convert JSON \(error.localizedDescription)")
            result = false
        }
        
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let pathWithFileName = documentDirectory.appendingPathComponent("profileData.json")
            do {
                try profileToJSON?.write(to: pathWithFileName)
                DispatchQueue.main.async {
                    self.currentProfile = profileData
                }
                result = true
//                result = false
            } catch {
                print("Error writeData \(error.localizedDescription)")
                result = false
            }
        }
        return result
    }
    
    func readData() -> ProfileModel {
//        sleep(5)
        guard let fileURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("profileData.json"),
              let jsonData = try? Data(contentsOf: fileURL) else { return defaultProfile }
        do {
            let profile = try JSONDecoder().decode(ProfileModel.self, from: jsonData)
//            print(fileURL)
            return profile
        } catch {
            print("Error read data \(error.localizedDescription)")
            return defaultProfile
        }
    }
}

//MARK: - DataManager + DataManagerObserver
extension DataManager: DataManagerObserver {
    func addSubscriber(subscriber: DataManagerSubscriber) {
        subscribers.append(subscriber)
    }
}
