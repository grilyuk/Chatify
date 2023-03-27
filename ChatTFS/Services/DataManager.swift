import UIKit
import Combine

protocol DataManagerProtocol: AnyObject {
    func readProfilePublisher() -> AnyPublisher<Data, Error>
    func writeData(profileData: ProfileModel) throws -> Bool
    func readData(queue: DispatchQueue) throws -> Data
}

class DataManager: DataManagerProtocol {
    
    //MARK: - Private properties
    private var backgroundQueue = DispatchQueue.global(qos: .utility)
    
    //MARK: - Methods
    private func checkPath() -> Bool {
        guard let filePath = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("profileData.json").path
        else {
            return false
        }
        return FileManager.default.fileExists(atPath: filePath) ? true : false
    }
    
    func readProfilePublisher() -> AnyPublisher<Data, Error> {
        Deferred {
            Future { promise in
                self.backgroundQueue.async {
                    do {
                        promise(.success(try self.readData(queue: self.backgroundQueue)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func writeProfilePublisher(profile: ProfileModel) -> AnyPublisher<Bool, Error> {
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
    
    func readData(queue: DispatchQueue) throws -> Data {
        guard let fileURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("profileData.json"),
              checkPath() == true,
              let jsonData = try? Data(contentsOf: fileURL)
        else {
            throw CustomError(description: "readData failed")
        }
        return jsonData
    }
    
    func writeData(profileData: ProfileModel) throws -> Bool {
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
                result = true
            } catch {
                print("Error writeData \(error.localizedDescription)")
                result = false
            }
        }
        return result
    }
    
}
