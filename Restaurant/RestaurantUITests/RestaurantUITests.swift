import XCTest

@MainActor
final class RestaurantUITests: XCTestCase {

	override func setUp() {
		continueAfterFailure = false
	}

	/// Registers a new account, then walks onboarding → menu → profile,
	/// running an accessibility audit on the screens that don't depend on the
	/// network, so the check stays deterministic on CI.
	func testOnboardingToMenuAndProfile() throws {
		let app = XCUIApplication()
		// Start logged out, and pin the language so the assertions below are
		// stable regardless of the device's locale.
		app.launchArguments = ["--uitesting-reset", "-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
		app.launch()

		// Onboarding is shown first.
		XCTAssertTrue(app.staticTexts["Create your account"].waitForExistence(timeout: 10))
		try auditAccessibility(app)

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
		try auditAccessibility(app)
	}

	/// Runs a full accessibility audit, ignoring one known false positive: the
	/// human-readable heuristic (`sufficientElementDescription`) flags an email
	/// address because it has no spaces and an "@", yet the email is legitimate,
	/// correctly labelled content. Every other finding, on every element, still
	/// fails the test.
	private func auditAccessibility(_ app: XCUIApplication) throws {
		try app.performAccessibilityAudit { issue in
			issue.auditType == .sufficientElementDescription
				&& (issue.element?.label.contains("@") ?? false)
		}
	}
}
