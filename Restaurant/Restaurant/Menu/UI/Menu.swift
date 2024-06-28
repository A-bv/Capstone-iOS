import SwiftUI

struct Menu: View {
	@ObservedObject private var viewModel = MenuViewModel()
	@Environment(\.managedObjectContext) private var viewContext
	@State private var searchText = ""
	
	private enum Constants {
		static let imageLength: CGFloat = 100
		static let imageCornerRadius: CGFloat = 8
		static let searchBarContainerHeight: CGFloat = 50
	}
	
	var body: some View {
		NavigationView {
			VStack(spacing: 0) {
				MenuHeroView()
				VStack {
					ExpandingSearchBar(searchText: $searchText, onSearchButtonClicked: {
						viewModel.applySearchFilter(searchText)
					})
					.frame(maxHeight: .infinity)
				}
				.frame(height: Constants.searchBarContainerHeight)
				//.border(Color.red, width: 1)
				
				MenuBreakdownView()

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
			.onAppear {
				viewModel.getMenuData(context: viewContext)
			}
			.onChange(of: searchText) {
				viewModel.applySearchFilter(searchText)
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
