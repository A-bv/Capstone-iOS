import SwiftUI

struct Menu: View {
	@State private var viewModel = MenuViewModel()
	@Environment(\.managedObjectContext) private var viewContext

	var body: some View {
		NavigationStack {
			VStack(spacing: 0) {
				MenuHeroView()

				MenuBreakdownView(viewModel: viewModel)

				if let errorMessage = viewModel.errorMessage {
					ContentUnavailableView {
						Label("Menu unavailable", systemImage: "wifi.exclamationmark")
					} description: {
						Text(errorMessage)
					} actions: {
						Button("Retry") {
							viewModel.getMenuData(context: viewContext)
						}
					}
					.frame(maxHeight: .infinity)
				} else if viewModel.isLoading && viewModel.filteredDishes.isEmpty {
					ProgressView("Loading menu…")
						.frame(maxHeight: .infinity)
				} else if viewModel.filteredDishes.isEmpty {
					ContentUnavailableView(
						"No dishes found",
						systemImage: "magnifyingglass",
						description: Text("Try a different search or category.")
					)
					.frame(maxHeight: .infinity)
				} else {
					List(viewModel.filteredDishes, id: \.objectID) { dish in
						NavigationLink(destination: MenuItemDetailView(dish: dish)) {
							MenuRow(dish: dish)
						}
					}
					.listStyle(.plain)
				}
			}
			.searchable(text: $viewModel.searchText, prompt: "Search the menu")
			.onAppear {
				viewModel.getMenuData(context: viewContext)
			}
			.onDisappear {
				viewModel.cancelLoading()
			}
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .principal) {
					HStack {
						Image("littleLemonBanner")
							.resizable()
							.scaledToFit()
							.padding(5)
							.accessibilityLabel("Little Lemon")
					}
				}
			}
		}
	}
}

struct MenuRow: View {
	let dish: Dish

	private enum Constants {
		static let imageSize: CGFloat = 80
		static let cornerRadius: CGFloat = 8
	}

	var body: some View {
		HStack(spacing: 12) {
			VStack(alignment: .leading, spacing: 4) {
				Text(dish.title ?? "")
					.font(.headline)
					.foregroundStyle(.primary)

				if let description = dish.itemDescription, !description.isEmpty {
					Text(description)
						.font(.subheadline)
						.foregroundStyle(.secondary)
						.lineLimit(2)
				}

				Text("$\(dish.price ?? "")")
					.font(.subheadline.weight(.semibold))
					.foregroundStyle(Color.darkGreenLittleLemon)
			}

			Spacer(minLength: 8)

			if let image = dish.image, let url = URL(string: image) {
				AsyncImage(url: url) { phase in
					switch phase {
					case .success(let image):
						image.resizable().aspectRatio(contentMode: .fill)
					case .failure:
						Image(systemName: "photo")
							.foregroundStyle(.secondary)
					case .empty:
						ProgressView()
					@unknown default:
						Color(.systemGray6)
					}
				}
				.frame(width: Constants.imageSize, height: Constants.imageSize)
				.background(Color(.systemGray6))
				.clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
				.accessibilityHidden(true)
			}
		}
		.padding(.vertical, 6)
		.accessibilityElement(children: .combine)
	}
}
