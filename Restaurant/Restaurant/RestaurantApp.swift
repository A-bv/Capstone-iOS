import SwiftUI

@main
struct RestaurantApp: App {
	@AppStorage(keyIsLoggedIn) private var isLoggedIn = false

	init() {
		// UI tests pass this flag to start from a clean, logged-out state.
		if ProcessInfo.processInfo.arguments.contains("--uitesting-reset") {
			[keyFirstName, keyLastName, keyEmail, keyIsLoggedIn].forEach {
				UserDefaults.standard.removeObject(forKey: $0)
			}
		}
	}

	var body: some Scene {
		WindowGroup {
			if isLoggedIn {
				Home()
			} else {
				Onboarding()
			}
		}
	}
}
