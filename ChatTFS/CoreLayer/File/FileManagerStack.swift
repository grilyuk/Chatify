import Foundation

protocol FileManagerStackProtocol {
    var fileManager: FileManager { get }
    var documentDirectory: URL { get }
}

final class FileManagerStack: FileManagerStackProtocol {
    var fileManager: FileManager = FileManager.default
    
    var documentDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
