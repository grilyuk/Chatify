import Foundation

protocol ServiceAssemblyProtocol: AnyObject {
    var coreDataService: CoreDataServiceProtocol { get }
    var themeService: ThemeServiceProtocol { get }
    var chatService: ChatServiceProtocol { get }
    var fileManagerService: FileManagerServiceProtocol { get }
    var imageLoaderService: ImageLoaderServiceProtocol { get }
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
    lazy var themeService: ThemeServiceProtocol = ThemeService()
    lazy var chatService: ChatServiceProtocol = ChatTFSService(chatTFS: coreAssembly.chatTFS)
    lazy var fileManagerService: FileManagerServiceProtocol = FileManagerService(fileManagerStack: coreAssembly.fileManagerStack)
    
    private lazy var networkService: NetworkServiceProtocol = NetworkService()
    lazy var imageLoaderService: ImageLoaderServiceProtocol = ImageLoaderService(networkService: networkService)
}
