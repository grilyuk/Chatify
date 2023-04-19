import Foundation

protocol ServiceAssemblyProtocol: AnyObject {
    var coreDataService: CoreDataServiceProtocol { get }
    var themeService: ThemeServiceProtocol { get }
    var chatService: ChatServiceProtocol { get }
//    var fileManagerService: FileManagerServiceProtocol { get }
}

final class ServiceAssembly: ServiceAssemblyProtocol {
    
    // MARK: - Initialization
    
    init(coreAssembly: CoreAssemblyProtocol) {
        self.coreAssembly = coreAssembly
    }
    
    // MARK: - Private properties
    
    private var coreAssembly: CoreAssemblyProtocol
    
    // MARK: - Public properties
    
    lazy var coreDataService: CoreDataServiceProtocol = CoreDataService(coreDataStack: coreAssembly.coreDataStack)
    
//    lazy var fileManagerService: FileManagerServiceProtocol = FileManagerService(
    
    lazy var themeService: ThemeServiceProtocol = ThemeService()
    
    lazy var chatService: ChatServiceProtocol = ChatTFSService(chatTFS: coreAssembly.chatTFS)
}
