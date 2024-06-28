import SwiftUI

struct Home: View {
	var body: some View {
		let persistenceController = PersistenceController.shared
		
		TabView {
			Menu()
				.environment(\.managedObjectContext, persistenceController.container.viewContext)
				.tabItem {
					Label("Menu", systemImage: "list.dash")
				}
			
			UserProfile()
				.tabItem {
					Label("Profile", systemImage: "square.and.pencil")
				}
		}
		.navigationBarBackButtonHidden(true)
	}
}

struct Home_Previews: PreviewProvider {
	static var previews: some View {
		Home()
	}
}
