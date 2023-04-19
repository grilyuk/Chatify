import Foundation

protocol ServiceAssemblyProtocol: AnyObject {
    var coreDataService: CoreDataServiceProtocol { get }
//    var fileManagerService: FileManagerServiceProtocol { get set }
}

final class ServiceAssembly: ServiceAssemblyProtocol {
    
    init(coreDataService: CoreDataServiceProtocol) {
        self.coreDataService = coreDataService
    }
    
    var coreDataService: CoreDataServiceProtocol
}
