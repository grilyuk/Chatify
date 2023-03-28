import UIKit
import Combine

protocol DataManagerProtocol: AnyObject {
    func readProfilePublisher() -> AnyPublisher<Data, Error>
    func writeProfilePublisher(profile: ProfileModel) -> AnyPublisher<ProfileModel, Error>
}

class DataManager: DataManagerProtocol {
    
    //MARK: - Private properties
    private var backgroundQueue = DispatchQueue.global(qos: .utility)
    private var currentProfile: CurrentValueSubject<ProfileModel, Error>?
    
    //MARK: - Methods
    
    
    func getCurrentProfile() {
        
    }
    
    func readProfilePublisher() -> AnyPublisher<Data, Error> {
        Deferred {
            Future { promise in
                self.backgroundQueue.async {
                    do {
                        promise(.success(try self.readData()))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func writeProfilePublisher(profile: ProfileModel) -> AnyPublisher<ProfileModel, Error> {
        Deferred {
            Future { promise in
                self.backgroundQueue.async {
                    do {
                        promise(.success(try self.writeData(profileData: profile)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func checkPath() -> Bool {
        guard let filePath = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("profileData.json").path
        else {
            return false
        }
        return FileManager.default.fileExists(atPath: filePath) ? true : false
    }
    
    func readData() throws -> Data {
        guard let fileURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("profileData.json"),
              checkPath() == true,
              let jsonData = try? Data(contentsOf: fileURL)
        else {
            throw CustomError(description: "readData failed")
        }
        return jsonData
    }
    
    func writeData(profileData: ProfileModel) throws -> ProfileModel {
        guard profileData.fullName != nil,
              profileData.statusText != nil
        else {
            return ProfileModel(fullName: nil, statusText: nil, profileImageData: nil)
        }
        return profileData
    }
    
}
