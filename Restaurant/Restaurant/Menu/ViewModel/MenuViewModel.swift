import CoreData
import OSLog

@MainActor
final class MenuViewModel: ObservableObject {
	private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "Restaurant", category: "MenuViewModel")

	@Published var dishes: [Dish] = []
	@Published var filteredDishes: [Dish] = []
	@Published var isLoading = false
	@Published var errorMessage: String?
	@Published var searchText: String = "" {
		didSet {
			updateFilteredDishes()
		}
	}

	private let urlString = "https://raw.githubusercontent.com/Meta-Mobile-Developer-PC/Working-With-Data-API/main/menu.json"

	func getMenuData(context: NSManagedObjectContext) {
		// Show whatever is already cached on disk first.
		fetchMenuItemsFromCoreData(context: context)

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
			updateFilteredDishes()
		} catch {
			logger.error("Failed to fetch menu from Core Data: \(error.localizedDescription, privacy: .public)")
		}
	}

	private func updateFilteredDishes() {
		let predicate = buildPredicate(searchText: searchText)
		filteredDishes = dishes.filter { predicate.evaluate(with: $0) }
	}

	func applySearchFilter(_ searchText: String) {
		self.searchText = searchText
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
