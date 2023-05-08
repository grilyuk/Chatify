import XCTest
@testable import ChatTFS

final class CoreDataServiceTests: XCTestCase {
    
    var coreDataService: CoreDataServiceProtocol!
    var coreDataStack: CoreDataStackProtocolMock!
    
    override func setUp() {
        super.setUp()
        coreDataStack = CoreDataStackProtocolMock()
        coreDataService = CoreDataService(coreDataStack: coreDataStack)
    }
    
    override func tearDown() {
        super.tearDown()
        coreDataStack = nil
        coreDataService = nil
    }
    
    func testGetChannelsFromDB() {
        // Act
        let channels = coreDataService.getChannelsFromDB()
        
        // Assert
        XCTAssertNotNil(channels)
    }
}
