import XCTest
@testable import ChatTFS

final class FileManagerServiceTests: XCTestCase {
    
    var fileManagerStack: FileManagerStackProtocolMock!
    var fileManagerService: FileManagerServiceProtocol!
    
    override func setUp() {
        super.setUp()
        fileManagerStack = FileManagerStackProtocolMock()
        fileManagerService = FileManagerService(fileManagerStack: fileManagerStack)
    }
    
    override func tearDown() {
        super.tearDown()
        fileManagerStack = nil
        fileManagerService = nil
    }
    
    func testGetChannelImage() {
        // Arrange
        let channel = ChannelNetworkModel(id: "\(UUID().uuidString)",
                                          name: "New channel",
                                          logoURL: nil,
                                          lastMessage: "Test message",
                                          lastActivity: Date())
        // Act
        _ = fileManagerService.getChannelImage(for: channel)
        
        // Assert
        XCTAssertEqual(fileManagerStack.invokedCheckPath, true)
        XCTAssertEqual(fileManagerStack.invokedCheckPathParameters?.fileName, channel.id)
    }
    
    func testCurrentProfile() {
        // Act
        fileManagerService.currentProfile
            .sink { profile in
                
                // Assert
                XCTAssertNotNil(profile)
            }
            .cancel()
    }
    
    func testUserId() {
        // Act
        _ = fileManagerService.userId
        
        // Assert
        XCTAssertEqual(fileManagerStack.invokedCheckPathCount, 1)
        XCTAssertEqual(fileManagerStack.invokedDocumentDirectoryGetter, true)
    }
    
    func testReadProfilePublisher() {
        // Act
        fileManagerService.readProfilePublisher()
            .sink { _ in
            } receiveValue: { [weak self] _ in
                // Assert
                
                guard let self else {
                    return
                }
                XCTAssertTrue(self.fileManagerStack.invokedDocumentDirectoryGetter)
                XCTAssertTrue(self.fileManagerStack.invokedCheckPath)
            }
            .cancel()
    }
}
