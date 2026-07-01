import SwiftUI

@main
struct RestaurantApp: App {
	@AppStorage(keyIsLoggedIn) private var isLoggedIn = false

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
