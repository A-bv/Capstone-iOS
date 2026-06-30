import XCTest
@testable import Restaurant

final class RestaurantTests: XCTestCase {

	// MARK: - Email validation

	func testValidEmailsPass() {
		let onboarding = Onboarding()
		XCTAssertTrue(onboarding.isValidEmail("jane.doe@example.com"))
		XCTAssertTrue(onboarding.isValidEmail("a+b@sub.domain.co"))
	}

	func testInvalidEmailsFail() {
		let onboarding = Onboarding()
		XCTAssertFalse(onboarding.isValidEmail(""))
		XCTAssertFalse(onboarding.isValidEmail("not-an-email"))
		XCTAssertFalse(onboarding.isValidEmail("missing@domain"))
		XCTAssertFalse(onboarding.isValidEmail("@example.com"))
	}

	// MARK: - Menu decoding

	func testDecodesDescriptionFromDescriptionKey() throws {
		let json = Data("""
		{ "menu": [
			{ "title": "Bruschetta", "image": "https://x/i.jpg", "price": "10", "description": "Grilled bread." }
		] }
		""".utf8)
		let list = try JSONDecoder().decode(MenuList.self, from: json)
		XCTAssertEqual(list.menu.first?.itemDescription, "Grilled bread.")
	}

	func testMissingDescriptionDecodesAsNil() throws {
		let json = Data("""
		{ "menu": [ { "title": "A", "image": "i", "price": "1" } ] }
		""".utf8)
		let list = try JSONDecoder().decode(MenuList.self, from: json)
		XCTAssertNil(list.menu.first?.itemDescription)
	}

	func testDecodesPriceWhetherStringOrNumber() throws {
		let stringPrice = Data(#"{ "menu": [ { "title": "A", "image": "i", "price": "10" } ] }"#.utf8)
		let intPrice = Data(#"{ "menu": [ { "title": "B", "image": "i", "price": 9 } ] }"#.utf8)
		let decimalPrice = Data(#"{ "menu": [ { "title": "C", "image": "i", "price": 9.5 } ] }"#.utf8)

		XCTAssertEqual(try JSONDecoder().decode(MenuList.self, from: stringPrice).menu.first?.price, "10")
		XCTAssertEqual(try JSONDecoder().decode(MenuList.self, from: intPrice).menu.first?.price, "9")
		XCTAssertEqual(try JSONDecoder().decode(MenuList.self, from: decimalPrice).menu.first?.price, "9.5")
	}

	// MARK: - Search predicate

	func testEmptySearchMatchesEverything() {
		let predicate = MenuViewModel().buildPredicate(searchText: "")
		XCTAssertTrue(predicate.evaluate(with: ["title": "Anything"]))
	}

	func testSearchIsCaseAndDiacriticInsensitive() {
		let predicate = MenuViewModel().buildPredicate(searchText: "brus")
		XCTAssertTrue(predicate.evaluate(with: ["title": "Bruschetta"]))
		XCTAssertFalse(predicate.evaluate(with: ["title": "Greek Salad"]))
	}
}
