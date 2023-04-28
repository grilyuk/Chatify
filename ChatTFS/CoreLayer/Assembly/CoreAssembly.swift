import Foundation

protocol CoreAssemblyProtocol: AnyObject {
    var coreDataStack: CoreDataStackProtocol { get }
    var fileManagerStack: FileManagerStack { get }
    var chatTFS: ChatTFS { get }
}

final class CoreAssembly: CoreAssemblyProtocol {
    lazy var coreDataStack: CoreDataStackProtocol = CoreDataStack()
    lazy var fileManagerStack: FileManagerStack = FileManagerStack()
    lazy var chatTFS: ChatTFS = ChatTFS()
}
