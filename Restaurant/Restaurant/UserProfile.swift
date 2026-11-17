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
							// Readable muted color: .secondary misses 4.5:1 for
							// small text, .primary at 60% clears it (both modes).
							.foregroundStyle(.primary.opacity(0.6))
							.multilineTextAlignment(.center)
							// Let a long email wrap instead of clipping at large
							// Dynamic Type sizes.
							.fixedSize(horizontal: false, vertical: true)
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
				// A deeper red than the system .red so the white label clears
				// 4.5:1 contrast; still clearly destructive.
				.tint(Color(red: 0.80, green: 0.12, blue: 0.11))
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
				.foregroundStyle(.primary.opacity(0.6))
				.fixedSize(horizontal: false, vertical: true)
			Spacer()
			Text(value)
				.multilineTextAlignment(.trailing)
				.fixedSize(horizontal: false, vertical: true)
		}
		.padding()
		.accessibilityElement(children: .combine)
	}
}

#Preview {
	UserProfile()
}
