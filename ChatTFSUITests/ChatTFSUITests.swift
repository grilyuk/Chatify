import XCTest

final class ChatTFSUITests: XCTestCase {
    
    let app = XCUIApplication()
    
    func testProfileViewElementsExist() {
        app.launch()
        
        app.tabBars["Tab Bar"].buttons["Profile"].tap()
        let nameLabel = app.staticTexts["nameLabel"]
        let addPhoto = app.buttons["Add photo"]
        let image = app.images["profilePhoto"]
        
        XCTAssert(addPhoto.exists)
        XCTAssert(nameLabel.exists)
        XCTAssert(image.exists)
    }
}
