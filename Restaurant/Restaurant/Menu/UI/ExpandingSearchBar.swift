import SwiftUI

struct ExpandingSearchBar: View {
	@Binding var searchText: String
	var onSearchButtonClicked: () -> Void
	@State private var isEditing = false
	
	private enum Constants {
		static let horizontalPadding: CGFloat = 8
		static let verticalPadding: CGFloat = 8
		static let cornerRadius: CGFloat = 10
		static let searchBarBackgroundColor: Color = Color(.systemGray6)
	}
	
	var body: some View {
		ZStack {
			Color.darkGreenLittleLemon
			
			HStack {
				if isEditing {
					TextField("Search", text: $searchText, onCommit: {
						onSearchButtonClicked()
					})
					.textFieldStyle(RoundedBorderTextFieldStyle())
					.padding(.leading, Constants.horizontalPadding)
					.transition(.move(edge: .trailing))
					.animation(.default, value: isEditing)
					
					Button(action: {
						self.isEditing = false
						searchText = ""
						onSearchButtonClicked()
						// Dismiss keyboard
						UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
					}) {
						Image(systemName: "xmark.circle.fill")
							.foregroundColor(.gray)
							.padding(.trailing, Constants.horizontalPadding)
					}
					.transition(.move(edge: .trailing))
					.animation(.default, value: isEditing)
				} else {
					Button(action: {
						self.isEditing = true
					}) {
						HStack {
							Image(systemName: "magnifyingglass")
								.foregroundColor(.gray)
							Text("Search")
								.foregroundColor(.gray)
						}
						.padding(.leading, Constants.horizontalPadding)
						.autocapitalization(.none)
						.disableAutocorrection(true)
					}
					.transition(.move(edge: .trailing))
					.animation(.default, value: isEditing)
				}
			}
			.padding(.horizontal, Constants.horizontalPadding)
			.padding(.vertical, Constants.verticalPadding)
			.background(Constants.searchBarBackgroundColor)
			.cornerRadius(Constants.cornerRadius)
			.animation(.default, value: isEditing)
		}
	}
}
