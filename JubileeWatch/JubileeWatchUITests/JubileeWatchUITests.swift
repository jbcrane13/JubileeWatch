import XCTest

final class JubileeWatchUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testTabNavigation() throws {
        // Test Dashboard is default
        XCTAssertTrue(app.staticTexts["JubileeWatch"].exists)
        
        // Navigate to Community
        app.tabBars.buttons["Community"].tap()
        XCTAssertTrue(app.staticTexts["Community"].exists)
        
        // Navigate to Map
        app.tabBars.buttons["Map"].tap()
        XCTAssertTrue(app.staticTexts["Jubilee Map"].exists)
        
        // Navigate to Trends
        app.tabBars.buttons["Trends"].tap()
        XCTAssertTrue(app.staticTexts["Trends & Analytics"].exists)
        
        // Navigate to Settings
        app.tabBars.buttons["Settings"].tap()
        XCTAssertTrue(app.staticTexts["Settings"].exists)
    }
    
    func testProbabilityGaugeExists() throws {
        // Go to Dashboard
        app.tabBars.buttons["Dashboard"].tap()
        
        // Check if probability gauge is visible
        XCTAssertTrue(app.staticTexts["Jubilee Probability"].exists)
    }
    
    func testCommunityChat() throws {
        // Navigate to Community
        app.tabBars.buttons["Community"].tap()
        
        // Check if chat is default view
        XCTAssertTrue(app.staticTexts["users online"].exists)
    }
    
    func testSettingsAccess() throws {
        // Navigate to Settings
        app.tabBars.buttons["Settings"].tap()
        
        // Test that settings sections exist
        XCTAssertTrue(app.staticTexts["Home Location"].exists)
        XCTAssertTrue(app.staticTexts["Notifications"].exists)
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}