import SwiftUI

struct MenuHeroView: View {
	// Seeded at the design size but scales with the user's Dynamic Type setting.
	@ScaledMetric(relativeTo: .title) private var titleSize: CGFloat = 30

	private enum Constants {
		static let headerHeight: CGFloat = 220
	}
	var body: some View {
		ZStack {
			Color.darkGreenLittleLemon
				.frame(height: Constants.headerHeight)
			
			HStack{
				VStack(alignment: .leading, spacing: 0) {
					VStack(alignment: .leading) {
						Text("Little Lemon")
							.font(.system(size: titleSize, weight: .medium))
							.foregroundColor(.yellowLittleLemon)
							
						Text("Chicago")
							.font(.subheadline)
							.foregroundColor(.white)
						Spacer()
					}
					.padding()
					.padding(.top, 50)
					
					Text("We are a family owned Mediterranean restaurant, focused on traditional recipes served with a modern twist.")
						.font(.body)
						.foregroundColor(.white)
						.padding()
						.padding(.bottom, 50)
						.fixedSize(horizontal: false, vertical: true)
					
				}

				Spacer()
				
				Image("MenuHeaderImage")
					.resizable()
					.aspectRatio(contentMode: .fill)
					.frame(width: 150, height: 150)
					.cornerRadius(10)
					.clipped()
					.padding(.trailing, 10)
					.accessibilityHidden(true)
			}
			.frame(height: Constants.headerHeight)
		}
	}
}

#Preview {
	MenuHeroView()
}
