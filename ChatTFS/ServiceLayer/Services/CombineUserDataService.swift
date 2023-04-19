import Foundation
import Combine

final class CombineUserDataService: UserDataProtocol {
    
    init(fileManagerStack: FileManagerStackProtocol) {
        self.fileManagerStack = fileManagerStack
    }
    
    var fileManagerStack: FileManagerStackProtocol
    
}
