import CoreData
import OSLog

@MainActor
final class MenuViewModel: ObservableObject {
	private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "Restaurant", category: "MenuViewModel")

	@Published var dishes: [Dish] = []
	@Published var filteredDishes: [Dish] = []
	@Published var categories: [String] = []
	@Published var isLoading = false
	@Published var errorMessage: String?
	@Published var searchText: String = "" {
		didSet {
			updateFilteredDishes()
		}
	}
	@Published var selectedCategory: String? {
		didSet {
			updateFilteredDishes()
		}
	}

	private let urlString = "https://raw.githubusercontent.com/Meta-Mobile-Developer-PC/Working-With-Data-API/main/menu.json"

	// Preferred display order; any categories the API adds later are appended alphabetically.
	private let categoryOrder = ["starters", "mains", "desserts", "drinks", "sides", "specials"]

	/// Selects a category, or clears the filter when the active one is tapped again.
	func toggleCategory(_ category: String) {
		selectedCategory = (selectedCategory == category) ? nil : category
	}

	func getMenuData(context: NSManagedObjectContext) {
		// Show whatever is already cached on disk first.
		fetchMenuItemsFromCoreData(context: context)

		// Refresh a cache written before dishes stored their category, so the
		// category filter has something to work with after an app update.
		if !dishes.isEmpty && dishes.contains(where: { ($0.category ?? "").isEmpty }) {
			dishes.forEach(context.delete)
			try? context.save()
			dishes = []
			updateFilteredDishes()
		}

		// Only hit the network the first time, when the cache is still empty.
		// This avoids re-downloading (and duplicating) the menu on every appear.
		guard dishes.isEmpty else { return }

		guard let url = URL(string: urlString) else {
			errorMessage = "The menu address is invalid."
			return
		}

		isLoading = true
		errorMessage = nil

		Task {
			do {
				let (data, _) = try await URLSession.shared.data(from: url)
				let menuList = try JSONDecoder().decode(MenuList.self, from: data)
				saveMenuItemsToCoreData(context: context, menuItems: menuList.menu)
				fetchMenuItemsFromCoreData(context: context)
			} catch let error as DecodingError {
				errorMessage = "Couldn't read the menu data.\n\(error.localizedDescription)"
			} catch {
				errorMessage = "Couldn't load the menu. Please check your connection and try again.\n\(error.localizedDescription)"
			}
			isLoading = false
		}
	}

	private func saveMenuItemsToCoreData(context: NSManagedObjectContext, menuItems: [MenuItem]) {
		for menuItem in menuItems {
			let dish = Dish(context: context)
			dish.title = menuItem.title
			dish.price = menuItem.price
			dish.itemDescription = menuItem.itemDescription
			dish.image = menuItem.image
			dish.category = menuItem.category
		}

		// Save once for the whole batch instead of on every item.
		do {
			try context.save()
		} catch {
			logger.error("Failed to save menu to Core Data: \(error.localizedDescription, privacy: .public)")
		}
	}

	private func fetchMenuItemsFromCoreData(context: NSManagedObjectContext) {
		let fetchRequest: NSFetchRequest<Dish> = Dish.fetchRequest()
		fetchRequest.sortDescriptors = buildSortDescriptors()

		do {
			dishes = try context.fetch(fetchRequest)
			updateCategories()
			updateFilteredDishes()
		} catch {
			logger.error("Failed to fetch menu from Core Data: \(error.localizedDescription, privacy: .public)")
		}
	}

	private func updateCategories() {
		let present = Set(dishes.compactMap { $0.category }.filter { !$0.isEmpty })
		categories = present.sorted { lhs, rhs in
			let li = categoryOrder.firstIndex(of: lhs) ?? Int.max
			let ri = categoryOrder.firstIndex(of: rhs) ?? Int.max
			return li == ri ? lhs < rhs : li < ri
		}
		// Drop a selection that no longer exists in the data.
		if let selected = selectedCategory, !present.contains(selected) {
			selectedCategory = nil
		}
	}

	private func updateFilteredDishes() {
		let predicate = buildPredicate(searchText: searchText)
		filteredDishes = dishes.filter { dish in
			let matchesCategory = selectedCategory == nil || dish.category == selectedCategory
			return matchesCategory && predicate.evaluate(with: dish)
		}
	}

	private func buildSortDescriptors() -> [NSSortDescriptor] {
		return [
			NSSortDescriptor(key: "title", ascending: true, selector: #selector(NSString.localizedStandardCompare))
		]
	}

	func buildPredicate(searchText: String) -> NSPredicate {
		return searchText.isEmpty ? NSPredicate(value: true) : NSPredicate(format: "title CONTAINS[cd] %@", searchText)
	}
}
