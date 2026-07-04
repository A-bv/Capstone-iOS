import SwiftUI

struct MenuItemDetailView: View {
	let dish: Dish

	private enum Constants {
		static let heroHeight: CGFloat = 260
	}

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 16) {
				if let image = dish.image, let url = URL(string: image) {
					AsyncImage(url: url) { phase in
						switch phase {
						case .success(let image):
							image.resizable().aspectRatio(contentMode: .fill)
						case .failure:
							Image(systemName: "photo")
								.font(.largeTitle)
								.foregroundStyle(.secondary)
						case .empty:
							ProgressView()
						@unknown default:
							Color(.systemGray6)
						}
					}
					.frame(height: Constants.heroHeight)
					.frame(maxWidth: .infinity)
					.background(Color(.systemGray6))
					.clipped()
					.accessibilityLabel(Text("Photo of \(dish.title ?? "the dish")"))
				}

				VStack(alignment: .leading, spacing: 12) {
					HStack(alignment: .firstTextBaseline) {
						Text(dish.title ?? "")
							.font(.title.bold())

						Spacer(minLength: 8)

						Text("$\(dish.price ?? "")")
							.font(.title3.weight(.semibold))
							.foregroundStyle(Color.darkGreenLittleLemon)
					}

					if let description = dish.itemDescription, !description.isEmpty {
						Text(description)
							.font(.body)
							.foregroundStyle(.secondary)
					}
				}
				.padding(.horizontal)
			}
			.padding(.bottom)
		}
		.navigationTitle(dish.title ?? "")
		.navigationBarTitleDisplayMode(.inline)
	}
}
