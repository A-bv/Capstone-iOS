import CoreData
import OSLog
import Observation

@MainActor
@Observable
final class MenuViewModel {
	private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "Restaurant", category: "MenuViewModel")

	var dishes: [Dish] = []
	var filteredDishes: [Dish] = []
	var categories: [String] = []
	var isLoading = false
	var errorMessage: String?
	var searchText: String = "" {
		didSet {
			updateFilteredDishes()
		}
	}
	var selectedCategory: String? {
		didSet {
			updateFilteredDishes()
		}
	}

	private let urlString = "https://raw.githubusercontent.com/Meta-Mobile-Developer-PC/Working-With-Data-API/main/menu.json"

	// Preferred display order; any categories the API adds later are appended alphabetically.
	private let categoryOrder = ["starters", "mains", "desserts", "drinks", "sides", "specials"]

	// A session with a shorter request timeout than URLSession.shared's 60s.
	private static let session: URLSession = {
		let config = URLSessionConfiguration.default
		config.timeoutIntervalForRequest = 15
		config.timeoutIntervalForResource = 30
		return URLSession(configuration: config)
	}()

	// Fetches the raw menu bytes. Injected so tests can supply canned data
	// instead of hitting the network.
	private let fetchData: (URL) async throws -> Data
	private var loadTask: Task<Void, Never>?

	init(fetchData: @escaping (URL) async throws -> Data = { try await MenuViewModel.session.data(from: $0).0 }) {
		self.fetchData = fetchData
	}

	// Fetches with one retry on a transient network error (a brief blip),
	// but fails fast on cancellation or a non-transient error like being offline.
	private func fetchWithRetry(_ url: URL) async throws -> Data {
		do {
			return try await fetchData(url)
		} catch let error as URLError where Self.isTransient(error) && !Task.isCancelled {
			logger.error("Menu fetch failed (\(error.code.rawValue)); retrying once.")
			try? await Task.sleep(for: .milliseconds(500))
			return try await fetchData(url)
		}
	}

	private static func isTransient(_ error: URLError) -> Bool {
		[.timedOut, .networkConnectionLost, .cannotConnectToHost, .dnsLookupFailed].contains(error.code)
	}

	/// Cancels an in-flight menu download, e.g. when the menu screen goes away.
	func cancelLoading() {
		loadTask?.cancel()
	}

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
			do {
				try context.save()
			} catch {
				logger.error("Failed to clear the stale menu cache: \(error.localizedDescription, privacy: .public)")
			}
			dishes = []
			updateFilteredDishes()
		}

		// Only hit the network the first time, when the cache is still empty and
		// no load is already running. Without the isLoading check, a rapid
		// re-appear (e.g. a tab switch) would start a second download while the
		// first is in flight and duplicate the whole menu.
		guard dishes.isEmpty, !isLoading else { return }

		guard let url = URL(string: urlString) else {
			errorMessage = String(localized: "The menu address is invalid.")
			return
		}

		isLoading = true
		errorMessage = nil

		loadTask = Task { await loadMenu(from: url, context: context) }
	}

	/// Downloads, decodes, and caches the menu. Separated from getMenuData so
	/// tests can await it directly with an injected fetch.
	func loadMenu(from url: URL, context: NSManagedObjectContext) async {
		do {
			let data = try await fetchWithRetry(url)
			let menuList = try JSONDecoder().decode(MenuList.self, from: data)
			saveMenuItemsToCoreData(context: context, menuItems: menuList.menu)
			fetchMenuItemsFromCoreData(context: context)
		} catch is CancellationError {
			// The screen went away mid-load; not a user-facing error.
		} catch let error as URLError where error.code == .cancelled {
			// URLSession surfaces cancellation as URLError.cancelled.
		} catch let error as DecodingError {
			errorMessage = String(localized: "Couldn't read the menu data.") + "\n" + error.localizedDescription
		} catch {
			errorMessage = String(localized: "Couldn't load the menu. Please check your connection and try again.") + "\n" + error.localizedDescription
		}
		isLoading = false
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
