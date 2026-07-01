import SwiftUI

struct MenuBreakdownView: View {
	@ObservedObject var viewModel: MenuViewModel

	var body: some View {
		Group {
			if !viewModel.categories.isEmpty {
				VStack(alignment: .leading, spacing: 12) {
					Text("ORDER FOR DELIVERY!")
						.font(.headline)
						.padding(.horizontal)

					ScrollView(.horizontal, showsIndicators: false) {
						HStack(spacing: 10) {
							CategoryChip(title: "All", isSelected: viewModel.selectedCategory == nil) {
								viewModel.selectedCategory = nil
							}

							ForEach(viewModel.categories, id: \.self) { category in
								CategoryChip(
									title: category.capitalized,
									isSelected: viewModel.selectedCategory == category
								) {
									viewModel.toggleCategory(category)
								}
							}
						}
						.padding(.horizontal)
					}
				}
				.padding(.vertical, 12)
			}
		}
	}
}

struct CategoryChip: View {
	let title: String
	let isSelected: Bool
	let action: () -> Void

	var body: some View {
		Button(action: action) {
			Text(title)
				.font(.subheadline.weight(.semibold))
				.padding(.horizontal, 16)
				.padding(.vertical, 8)
				.background(isSelected ? Color.darkGreenLittleLemon : Color(.systemGray6))
				.foregroundColor(isSelected ? .white : .darkGreenLittleLemon)
				.clipShape(Capsule())
		}
		.buttonStyle(.plain)
	}
}

#Preview {
	let viewModel = MenuViewModel()
	viewModel.categories = ["starters", "mains", "desserts"]
	return MenuBreakdownView(viewModel: viewModel)
}
