import SwiftUI

struct MenuBreakdownView: View {
	var viewModel: MenuViewModel

	var body: some View {
		Group {
			if !viewModel.categories.isEmpty {
				VStack(alignment: .leading, spacing: 12) {
					Text("ORDER FOR DELIVERY!")
						.font(.headline)
						.padding(.horizontal)

					ScrollView(.horizontal, showsIndicators: false) {
						HStack(spacing: 10) {
							CategoryChip(title: NSLocalizedString("All", comment: "Show every category"), isSelected: viewModel.selectedCategory == nil) {
								viewModel.selectedCategory = nil
							}

							ForEach(viewModel.categories, id: \.self) { category in
								CategoryChip(
									title: NSLocalizedString(category.capitalized, comment: "Menu category"),
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
				.sensoryFeedback(.selection, trigger: viewModel.selectedCategory)
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
				.padding(.horizontal, Spacing.large)
				.padding(.vertical, Spacing.small)
				.background(isSelected ? Color.darkGreenLittleLemon : Color(.systemGray6))
				.foregroundColor(isSelected ? .white : .darkGreenLittleLemon)
				.clipShape(Capsule())
				.animation(.snappy, value: isSelected)
		}
		.buttonStyle(.plain)
		.accessibilityAddTraits(isSelected ? [.isSelected] : [])
	}
}

#Preview {
	let viewModel = MenuViewModel()
	viewModel.categories = ["starters", "mains", "desserts"]
	return MenuBreakdownView(viewModel: viewModel)
}
