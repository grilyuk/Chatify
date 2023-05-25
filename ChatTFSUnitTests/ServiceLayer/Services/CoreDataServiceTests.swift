import XCTest
import CoreData
@testable import ChatTFS

final class CoreDataServiceTests: XCTestCase {
    
    var coreDataService: CoreDataServiceProtocol!
    var coreDataStack: CoreDataStackProtocolMock!
    var id: String!
    var channel: ChannelNetworkModel!
    
    override func setUp() {
        super.setUp()
        coreDataStack = CoreDataStackProtocolMock()
        coreDataService = CoreDataService(coreDataStack: coreDataStack)
        id = UUID().uuidString
        channel = ChannelNetworkModel(id: "", name: "", logoURL: nil, lastMessage: nil, lastActivity: nil)
    }
    
    override func tearDown() {
        super.tearDown()
        coreDataStack = nil
        coreDataService = nil
        id = nil
        channel = nil
    }
    
    func testGetChannelsFromDB() {
        // Act
        _ = coreDataService.getChannelsFromDB()
        
        // Assert
        XCTAssert(coreDataStack.invokedFetchChannelsList)
    }
    
    func testGetDBChannel() {
        // Act
        _ = coreDataService.getDBChannel(channel: id)

        // Assert
        XCTAssert(coreDataStack.invokedFetchChannel)
    }
    
    func testDelete() {
        // Act
        _ = coreDataService.deleteChannel(channelID: id)
        
        // Assert
        XCTAssert(coreDataStack.invokedFetchChannel)
    }
    
    func testSaveChannel() {
        // Act
        coreDataService.saveChannelsList(with: [channel])

        // Assert
        XCTAssert(coreDataStack.invokedSave)
    }
    
    func testUpdateChannel() {
        // Act
        coreDataService.updateChannel(for: channel)
        
        // Assert
        XCTAssertNoThrow(coreDataStack.invokedUpdateParameters?.channel)
        XCTAssert(coreDataStack.invokedUpdate)
    }
    
    func testSaveMessagesToChannel() {
        // Arrange
        let message = MessageNetworkModel()
        
        // Act
        coreDataService.saveMessagesForChannel(for: id, messages: [message])
        
        // Assert
        XCTAssert(coreDataStack.invokedSave)
    }
    
    func testGetMessagesForChannel() {
        // Act
        _ = coreDataService.getMessagesFromDBChannel(channel: id)
        
        // Assert
        XCTAssertNotNil(try coreDataStack.fetchChannelMessages(for: id))
        XCTAssert(coreDataStack.invokedFetchChannelMessages)
    }
}
