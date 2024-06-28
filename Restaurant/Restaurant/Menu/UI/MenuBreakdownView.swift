import SwiftUI

struct MenuBreakdownView: View {
	var body: some View {
		VStack(alignment: .leading, spacing: 0) {
			Text("ORDER FOR DELIVERY!")
				.font(.system(size: 15, weight: .medium))
				.fontWeight(.bold)
				.padding(.leading)
				.padding(.top, 20)
			
			HStack {
				CategoryButton(title: "Starters")
				CategoryButton(title: "Mains")
				CategoryButton(title: "Desserts")
				CategoryButton(title: "Drinks")
			}
			.padding()
		}
	}
}

struct CategoryButton: View {
	@State private var showAlert = false
	var title: String
	
	var body: some View {
		Button(action: {
			showAlert = true
		}) {
			Text(title)
				.bold()
				.padding(10)
				.background(Color.gray.opacity(0.2))
				.cornerRadius(10)
				.foregroundColor(.darkGreenLittleLemon)
		}
		.alert(isPresented: $showAlert) {
			Alert(title: Text("Showcase button"), message: Text("This button is provided for illustrative purposes; please use the search bar to filter."), dismissButton: .default(Text("OK")))
		}
	}
}

struct DeliveryMenuView_Previews: PreviewProvider {
	static var previews: some View {
		MenuBreakdownView()
	}
}
