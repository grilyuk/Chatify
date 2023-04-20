import UIKit
import Combine

protocol FileManagerServiceProtocol: AnyObject {
    
    var currentProfile: CurrentValueSubject<ProfileModel, Never> { get set }
    var userId: String { get }
    
    func readProfilePublisher() -> AnyPublisher<Data, Error>
    func writeProfilePublisher(profile: ProfileModel) -> AnyPublisher<ProfileModel, Error>
    func getChannelImage(for channel: ChannelNetworkModel) -> UIImage
}

class FileManagerService: FileManagerServiceProtocol {
    
    // MARK: - Initialization
    
    init(fileManagerStack: FileManagerStackProtocol) {
        self.fileManagerStack = fileManagerStack
    }

    static var defaultProfile = ProfileModel(fullName: nil, statusText: nil, profileImageData: nil)
    var currentProfile = CurrentValueSubject<ProfileModel, Never>(defaultProfile)
    var userId: String {
        readUserID(fileName: FileManagerService.userIdFileName)
    }
    
    // MARK: - Private properties
    
    private let fileManagerStack: FileManagerStackProtocol
    static let profileFileName = "profileData.json"
    static let userIdFileName = "userId.json"
    
    private var backgroundQueue = DispatchQueue.global(qos: .utility)
    
    // MARK: - Publishers
    
    func readProfilePublisher() -> AnyPublisher<Data, Error> {
        Deferred {
            Future { promise in
                self.backgroundQueue.async {
                    do {
                        promise(.success(try self.readData(fileName: FileManagerService.profileFileName)))
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
    
    // MARK: - Public methods
    
    func getChannelImage(for channel: ChannelNetworkModel) -> UIImage {
        
        let placeholder = UIImage.channelPlaceholder
        
        if checkPath(fileName: channel.id) {
            do {
                let path = fileManagerStack.documentDirectory
                    .appendingPathComponent(channel.id)
                let imageData = try Data(contentsOf: path)
                
                return UIImage(data: imageData) ?? placeholder
            } catch {
                print(error.localizedDescription)
                
                return placeholder
            }
        } else {
            
            guard
                let stringURL = channel.logoURL,
                let url = URL(string: stringURL)
            else {
                
                return placeholder
            }
            
            do {
                let imageData = try Data(contentsOf: url)
                saveImageData(for: channel.id, data: imageData)
                return UIImage(data: imageData) ?? placeholder
            } catch {
                print(error)
                return placeholder
            }
        }
    }
    
    // MARK: - Private methods
    
    private func readUserID(fileName: String) -> String {
        let fileURL = fileManagerStack.documentDirectory
            .appendingPathComponent(fileName)
        if checkPath(fileName: fileName) {
            do {
                let jsonData = try Data(contentsOf: fileURL)
                let userId = try JSONDecoder().decode(String.self, from: jsonData)
                return userId
            } catch {
                print(CustomError(description: "Error decoding userID"))
            }
        } else {
            guard let deviceId = UIDevice.current.identifierForVendor else { return "" }
            let userId = deviceId.uuidString
            do {
                let userIdData = try JSONEncoder().encode(userId)
                try userIdData.write(to: fileURL)
                return userId
            } catch {
                print(CustomError(description: "Error encoding userID"))
            }
        }
        return ""
    }
    
    private func checkPath(fileName: String) -> Bool {
        let filePath = fileManagerStack.documentDirectory
            .appendingPathComponent(fileName).path
        return FileManager.default.fileExists(atPath: filePath) ? true : false
    }
    
    private func readData(fileName: String) throws -> Data {
        let fileURL = fileManagerStack.documentDirectory
            .appendingPathComponent(fileName)
        guard checkPath(fileName: fileName) == true,
              let jsonData = try? Data(contentsOf: fileURL)
        else {
            throw CustomError(description: "readData failed")
        }
        return jsonData
    }
    
    private func writeData(profileData: ProfileModel) throws -> ProfileModel {
        guard profileData.fullName != nil,
              profileData.statusText != nil
        else {
            return ProfileModel(fullName: nil, statusText: nil, profileImageData: nil)
        }
        return profileData
    }
    
    private func saveImageData(for id: String, data: Data) {
        let fileURL = fileManagerStack.documentDirectory
            .appendingPathComponent(id)
        
        do {
            try data.write(to: fileURL)
        } catch {
            print(error)
        }
    }
}
