import XCTest

final class TickTaskUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunchCreateSearchFilterAndSettingsSurface() throws {
        let app = XCUIApplication()
        app.launchArguments = ["UITestMode"]
        app.launch()

        XCTAssertTrue(app.navigationBars["Today"].waitForExistence(timeout: 5))

        let addButton = app.buttons["Add Task"]
        if addButton.exists {
            addButton.tap()
        } else {
            app.buttons["CreateTaskEmptyStateButton"].tap()
        }

        let titleField = app.textFields["Title"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 3))
        titleField.tap()
        titleField.typeText("UI Test Task")
        app.buttons["SaveTaskButton"].tap()

        XCTAssertTrue(app.staticTexts["UI Test Task"].waitForExistence(timeout: 3))
        app.staticTexts["UI Test Task"].tap()
        XCTAssertTrue(app.navigationBars["Task"].waitForExistence(timeout: 3))
        app.navigationBars.buttons.element(boundBy: 0).tap()

        app.textFields["SearchTasksTextField"].tap()
        app.textFields["SearchTasksTextField"].typeText("UI Test")
        XCTAssertTrue(app.staticTexts["UI Test Task"].exists)

        app.buttons["FilterAll"].tap()
        app.buttons["FilterCompleted"].tap()

        app.navigationBars["Today"].buttons["Settings"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.switches["HapticsToggle"].exists || app.cells["Enabled"].exists)
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
