import SwiftUI

struct MenuItemDetailView: View {
	let dish: Dish
	
	var body: some View {
		VStack {
			if let imageUrlString = dish.image, let imageUrl = URL(string: imageUrlString) {
				AsyncImage(url: imageUrl) { image in
					image.resizable()
						.aspectRatio(contentMode: .fit)
				} placeholder: {
					ProgressView()
				}
				.frame(maxWidth: .infinity)
			}
			
			Text(dish.title ?? "")
				.font(.title)
				.padding()
			
			Text("Price: $\(dish.price ?? "")")
				.font(.headline)
			
			Spacer()
		}
		.navigationTitle("Dish Details")
	}
}
