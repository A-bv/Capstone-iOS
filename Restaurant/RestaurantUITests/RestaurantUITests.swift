import XCTest

@MainActor
final class RestaurantUITests: XCTestCase {

	override func setUp() {
		continueAfterFailure = false
	}

	/// Registers a new account, then walks onboarding → menu → profile.
	func testOnboardingToMenuAndProfile() {
		let app = XCUIApplication()
		app.launchArguments = ["--uitesting-reset"] // start logged out with a clean slate
		app.launch()

		// Onboarding is shown first.
		XCTAssertTrue(app.staticTexts["Create your account"].waitForExistence(timeout: 10))

		app.textFields["First Name"].tap()
		app.textFields["First Name"].typeText("Jane")
		app.textFields["Last Name"].tap()
		app.textFields["Last Name"].typeText("Doe")
		app.textFields["Email"].tap()
		app.textFields["Email"].typeText("jane@example.com")

		let register = app.buttons["Register"]
		XCTAssertTrue(register.isEnabled, "Register should enable once the form is valid")
		register.tap()

		// Registering swaps the root to the tabbed home.
		XCTAssertTrue(app.tabBars.buttons["Profile"].waitForExistence(timeout: 10))
		XCTAssertTrue(app.tabBars.buttons["Menu"].exists)

		// The profile tab shows the account we just created.
		app.tabBars.buttons["Profile"].tap()
		XCTAssertTrue(app.staticTexts["Jane Doe"].waitForExistence(timeout: 5))
	}
}
