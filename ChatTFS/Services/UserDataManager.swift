//import Foundation
//
//protocol DataManagerProtocol: AnyObject {
//    var profileData: ProfileModel? { get set }
//}
//
//class DataManager: DataManagerProtocol {
//    
//    var profileData: ProfileModel?
//    
//    func writeData(name: String?, statusText: String?, profileImage: UIImage?, completion: @escaping (Result<Bool, Error>) -> Void) {
//        
//        sleep(5)
//        if profileImage == nil {
//            self.imageData = nil
//        } else {
//            self.imageData = profileImage?.jpegData(compressionQuality: 1)
//        }
//        
//        let profileData = ProfileModel(fullName: name, statusText: statusText, profileImageData: self.imageData)
//        var profileToJSON: Data?
//        
//        do {
//            profileToJSON = try JSONEncoder().encode(profileData)
//        } catch {
//            print(error.localizedDescription)
//        }
//        
//        guard let jsonData = profileToJSON else { return }
//        
//        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
//            let pathWithFileName = documentDirectory.appendingPathComponent("profileData.json")
//            do {
//                try jsonData.write(to: pathWithFileName)
//                completion(.success(true))
//            } catch {
//                completion(.failure(error))
//            }
//        }
//        
//    }
//    
//    func readData(completion: @escaping (Result<ProfileModel, Error>) -> Void) {
//        guard let fileURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("profileData.json"),
//              let jsonData = try? Data(contentsOf: fileURL)
//        else { return }
//        do {
//            let profile = try JSONDecoder().decode(ProfileModel.self, from: jsonData)
//            completion(.success(profile))
//        } catch {
//            completion(.failure(error))
//        }
//    }
//}
