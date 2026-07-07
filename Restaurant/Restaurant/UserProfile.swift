import SwiftUI

struct UserProfile: View {
	@AppStorage(keyIsLoggedIn) private var isLoggedIn = false

	let firstName = UserDefaults.standard.string(forKey: keyFirstName) ?? ""
	let lastName = UserDefaults.standard.string(forKey: keyLastName) ?? ""
	let email = UserDefaults.standard.string(forKey: keyEmail) ?? ""

	private var initials: String {
		let first = firstName.first.map(String.init) ?? ""
		let last = lastName.first.map(String.init) ?? ""
		let value = (first + last).uppercased()
		return value.isEmpty ? "?" : value
	}

	var body: some View {
		NavigationStack {
			VStack(spacing: 24) {
				VStack(spacing: 12) {
					ZStack {
						Circle().fill(Color.darkGreenLittleLemon)
						Text(initials)
							.font(.largeTitle.bold())
							.foregroundStyle(.white)
					}
					.frame(width: 96, height: 96)
					.accessibilityHidden(true)

					Text("\(firstName) \(lastName)")
						.font(.title2.bold())

					if !email.isEmpty {
						Text(email)
							.font(.subheadline)
							.foregroundStyle(.secondary)
					}
				}
				.padding(.top, 24)

				VStack(spacing: 0) {
					ProfileRow(label: "First name", value: firstName)
					Divider()
					ProfileRow(label: "Last name", value: lastName)
					Divider()
					ProfileRow(label: "Email", value: email)
				}
				.background(Color(.systemGray6))
				.clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
				.padding(.horizontal)

				Spacer()

				Button(role: .destructive) {
					isLoggedIn = false
				} label: {
					Text("Log out")
						.font(.headline)
						.frame(maxWidth: .infinity)
						.padding()
				}
				.buttonStyle(.borderedProminent)
				.tint(.red)
				.padding(.horizontal)
				.padding(.bottom)
			}
			.navigationTitle("Profile")
		}
	}
}

struct ProfileRow: View {
	let label: LocalizedStringKey
	let value: String

	var body: some View {
		HStack {
			Text(label)
				.foregroundStyle(.secondary)
			Spacer()
			Text(value)
				.multilineTextAlignment(.trailing)
		}
		.padding()
		.accessibilityElement(children: .combine)
	}
}

#Preview {
	UserProfile()
}
