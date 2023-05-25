import Foundation

protocol FileManagerStackProtocol {
    var fileManager: FileManager { get }
    var documentDirectory: URL { get }
    func checkPath(fileName: String) -> Bool
}

final class FileManagerStack: FileManagerStackProtocol {
    var fileManager: FileManager = FileManager.default
    
    var documentDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func checkPath(fileName: String) -> Bool {
        let filePath = documentDirectory
            .appendingPathComponent(fileName).path
        return fileManager.fileExists(atPath: filePath) ? true : false
    }
}
