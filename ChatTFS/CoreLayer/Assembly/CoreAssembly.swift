import Foundation

protocol CoreAssemblyProtocol: AnyObject {
    var coreDataStack: CoreDataStackProtocol { get }
    var fileManagerStack: FileManagerStack { get }
}

final class CoreAssembly: CoreAssemblyProtocol {
    lazy var coreDataStack: CoreDataStackProtocol = CoreDataStack()
    lazy var fileManagerStack: FileManagerStack = FileManagerStack()
}
