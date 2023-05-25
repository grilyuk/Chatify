import Foundation
@testable import ChatTFS

class FileManagerStackProtocolMock: FileManagerStackProtocol {

    var invokedFileManagerGetter = false
    var invokedFileManagerGetterCount = 0
    var stubbedFileManager: FileManager!

    var fileManager: FileManager {
        invokedFileManagerGetter = true
        invokedFileManagerGetterCount += 1
        return stubbedFileManager
    }

    var invokedDocumentDirectoryGetter = false
    var invokedDocumentDirectoryGetterCount = 0
    var stubbedDocumentDirectory: URL = URL(fileURLWithPath: "")

    var documentDirectory: URL {
        invokedDocumentDirectoryGetter = true
        invokedDocumentDirectoryGetterCount += 1
        return stubbedDocumentDirectory
    }

    var invokedCheckPath = false
    var invokedCheckPathCount = 0
    var invokedCheckPathParameters: (fileName: String, Void)?
    var invokedCheckPathParametersList = [(fileName: String, Void)]()

    func checkPath(fileName: String) -> Bool {
        invokedCheckPath = true
        invokedCheckPathCount += 1
        invokedCheckPathParameters = (fileName, ())
        invokedCheckPathParametersList.append((fileName, ()))
        return invokedCheckPath
    }
}
