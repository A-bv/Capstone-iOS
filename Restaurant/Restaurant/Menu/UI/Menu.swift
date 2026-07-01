import SwiftUI

struct Menu: View {
	@StateObject private var viewModel = MenuViewModel()
	@Environment(\.managedObjectContext) private var viewContext

	private enum Constants {
		static let imageLength: CGFloat = 100
		static let imageCornerRadius: CGFloat = 8
	}
	
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
				} else {
					List(viewModel.filteredDishes, id: \.title) { item in
						NavigationLink(destination: MenuItemDetailView(dish: item)) {
							HStack {
								Text("\(item.title ?? "") - $\(item.price ?? "")")
									.font(.headline)

								Spacer()

								if let imageUrl = item.image, let url = URL(string: imageUrl) {
									AsyncImage(
										url: url,
										content: { image in
											image.resizable()
												.aspectRatio(contentMode: .fit)
										},
										placeholder: {
											ProgressView()
										}
									)
									.cornerRadius(Constants.imageCornerRadius)
									.frame(width: Constants.imageLength, height: Constants.imageLength)
								}
							}
						}
					}
					.listStyle(.plain)
				}
			}
			.searchable(text: $viewModel.searchText, prompt: "Search the menu")
			.onAppear {
				viewModel.getMenuData(context: viewContext)
			}
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .principal) {
					HStack {
						Image("littleLemonBanner")
							.resizable()
							.scaledToFit()
							.padding(5)
					}
				}
			}
		}
	}
}
