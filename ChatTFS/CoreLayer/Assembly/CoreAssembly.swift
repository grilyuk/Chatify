import Foundation

protocol CoreAssemblyProtocol: AnyObject {
    var coreDataStack: CoreDataProtocol { get }
    var fileManagerStack: FileManagerStack { get }
}

final class CoreAssembly: CoreAssemblyProtocol {
    lazy var coreDataStack: CoreDataProtocol = CoreDataStack()
    lazy var fileManagerStack: FileManagerStack = FileManagerStack()
}
