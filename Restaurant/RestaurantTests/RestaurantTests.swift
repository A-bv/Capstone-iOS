import XCTest
import CoreData
@testable import Restaurant

@MainActor
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

	// MARK: - View model behavior (in-memory store)

	private func makeContext() -> NSManagedObjectContext {
		PersistenceController(inMemory: true).container.viewContext
	}

	@discardableResult
	private func insertDish(_ title: String, category: String?, in context: NSManagedObjectContext) -> Dish {
		let dish = Dish(context: context)
		dish.title = title
		dish.category = category
		dish.price = "10"
		dish.image = "https://example.com/\(title).jpg"
		return dish
	}

	func testCategoriesDerivedInCanonicalOrder() {
		let context = makeContext()
		insertDish("Lemon Tart", category: "desserts", in: context)
		insertDish("Greek Salad", category: "starters", in: context)
		insertDish("Grilled Fish", category: "mains", in: context)
		try? context.save()

		let viewModel = MenuViewModel()
		viewModel.getMenuData(context: context) // cache present, so no network

		XCTAssertEqual(viewModel.categories, ["starters", "mains", "desserts"])
	}

	func testFilterCombinesCategoryAndSearch() {
		let context = makeContext()
		insertDish("Bruschetta", category: "starters", in: context)
		insertDish("Greek Salad", category: "starters", in: context)
		insertDish("Grilled Fish", category: "mains", in: context)
		try? context.save()

		let viewModel = MenuViewModel()
		viewModel.getMenuData(context: context)

		viewModel.selectedCategory = "starters"
		XCTAssertEqual(Set(viewModel.filteredDishes.compactMap { $0.title }), ["Bruschetta", "Greek Salad"])

		viewModel.searchText = "greek"
		XCTAssertEqual(viewModel.filteredDishes.compactMap { $0.title }, ["Greek Salad"])

		viewModel.selectedCategory = nil
		XCTAssertEqual(viewModel.filteredDishes.compactMap { $0.title }, ["Greek Salad"])
	}

	func testToggleCategorySelectsThenClears() {
		let viewModel = MenuViewModel()
		viewModel.toggleCategory("mains")
		XCTAssertEqual(viewModel.selectedCategory, "mains")
		viewModel.toggleCategory("mains")
		XCTAssertNil(viewModel.selectedCategory)
	}

	func testPopulatedCacheIsNotRefetched() {
		let context = makeContext()
		insertDish("Bruschetta", category: "starters", in: context)
		try? context.save()

		var fetchCount = 0
		let viewModel = MenuViewModel(fetchData: { _ in fetchCount += 1; return Data() })
		viewModel.getMenuData(context: context)

		XCTAssertEqual(fetchCount, 0, "A populated cache must not trigger a network fetch")
		XCTAssertEqual(viewModel.dishes.count, 1)
	}

	func testConcurrentLoadsFetchOnlyOnce() async {
		let context = makeContext() // empty cache
		let json = Data("""
		{ "menu": [
			{ "title": "Bruschetta", "image": "https://x/b.jpg", "price": "10", "category": "starters" },
			{ "title": "Grilled Fish", "image": "https://x/f.jpg", "price": "20", "category": "mains" }
		] }
		""".utf8)

		var fetchCount = 0
		let viewModel = MenuViewModel(fetchData: { _ in fetchCount += 1; return json })

		// Two appears in quick succession, before the first load finishes.
		viewModel.getMenuData(context: context)
		viewModel.getMenuData(context: context)

		var spins = 0
		while viewModel.isLoading && spins < 1000 {
			await Task.yield()
			spins += 1
		}

		XCTAssertEqual(fetchCount, 1, "A second appear must not start another download")
		XCTAssertEqual(viewModel.dishes.count, 2, "The menu must not be duplicated")
	}

	func testNetworkLoadPopulatesDishesAndCategories() async {
		let context = makeContext() // empty
		let json = Data("""
		{ "menu": [
			{ "title": "Bruschetta", "image": "https://x/b.jpg", "price": "10", "description": "Tomatoes.", "category": "starters" },
			{ "title": "Grilled Fish", "image": "https://x/f.jpg", "price": "20", "description": "Fresh.", "category": "mains" }
		] }
		""".utf8)

		let viewModel = MenuViewModel(fetchData: { _ in json })
		await viewModel.loadMenu(from: URL(string: "https://example.com/menu.json")!, context: context)

		XCTAssertEqual(viewModel.dishes.count, 2)
		XCTAssertEqual(viewModel.categories, ["starters", "mains"])
		XCTAssertFalse(viewModel.isLoading)
		XCTAssertNil(viewModel.errorMessage)
	}
}
