import SwiftUI

struct MenuHeroView: View {
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
							.font(.system(size: 30, weight: .medium))
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
			}
			.frame(height: Constants.headerHeight)
		}
	}
}

struct MenuHeaderView_Previews: PreviewProvider {
	static var previews: some View {
		MenuHeroView()
	}
}
