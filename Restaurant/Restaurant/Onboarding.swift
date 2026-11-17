import SwiftUI

let keyFirstName = "firstNameKey"
let keyLastName = "lastNameKey"
let keyEmail = "emailKey"
let keyIsLoggedIn = "isLoggedInKey"

struct Onboarding: View {
	@AppStorage(keyIsLoggedIn) private var isLoggedIn = false
	@State private var firstName = ""
	@State private var lastName = ""
	@State private var email = ""

	private var isEmailValid: Bool { isValidEmail(email) }
	private var isFormValid: Bool {
		!firstName.trimmingCharacters(in: .whitespaces).isEmpty
			&& !lastName.trimmingCharacters(in: .whitespaces).isEmpty
			&& isEmailValid
	}

	var body: some View {
		NavigationStack {
			ScrollView {
				VStack(spacing: 28) {
					header

					VStack(spacing: 16) {
						OnboardingField(title: "First Name", text: $firstName)
						OnboardingField(title: "Last Name", text: $lastName)
						OnboardingField(
							title: "Email",
							text: $email,
							keyboardType: .emailAddress,
							autocapitalization: .never,
							footer: (!email.isEmpty && !isEmailValid) ? "Enter a valid email address." : nil
						)
					}

					Button(action: register) {
						Text("Register")
							.font(.headline)
							.frame(maxWidth: .infinity)
							.padding()
							.background(isFormValid ? Color.yellowLittleLemon : Color(.systemGray4))
							// The disabled label was systemGray on systemGray4 (~2:1);
					// primary at 60% keeps the muted, disabled look while clearing
					// the WCAG contrast bar in both light and dark.
					.foregroundStyle(isFormValid ? Color.darkGreenLittleLemon : Color.primary.opacity(0.6))
							.clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
					}
					.disabled(!isFormValid)

					Spacer(minLength: 0)
				}
				.padding()
			}
			.sensoryFeedback(.success, trigger: isLoggedIn)
		}
	}

	private var header: some View {
		VStack(spacing: 10) {
			Image("littleLemonBanner")
				.resizable()
				.scaledToFit()
				.frame(height: 64)
				.accessibilityLabel("Little Lemon")

			Text("Create your account")
				.font(.title2.bold())
				.foregroundStyle(Color.darkGreenLittleLemon)

			Text("Register to start ordering from Little Lemon.")
				.font(.subheadline)
				// .primary at 60% stays adaptive for dark mode but clears the
				// 4.5:1 WCAG contrast bar that the system .secondary color misses
				// for small text on white.
				.foregroundStyle(.primary.opacity(0.6))
				.multilineTextAlignment(.center)
		}
		.padding(.top, 32)
	}

	private func register() {
		guard isFormValid else { return }
		UserDefaults.standard.set(firstName, forKey: keyFirstName)
		UserDefaults.standard.set(lastName, forKey: keyLastName)
		UserDefaults.standard.set(email, forKey: keyEmail)
		isLoggedIn = true
	}

	func isValidEmail(_ email: String) -> Bool {
		let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
		let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
		return emailTest.evaluate(with: email)
	}
}

struct OnboardingField: View {
	let title: LocalizedStringKey
	@Binding var text: String
	var keyboardType: UIKeyboardType = .default
	var autocapitalization: TextInputAutocapitalization = .sentences
	var footer: LocalizedStringKey? = nil

	var body: some View {
		VStack(alignment: .leading, spacing: 6) {
			Text(title)
				.font(.caption.weight(.semibold))
				.foregroundStyle(.secondary)
				.accessibilityHidden(true)

			TextField(title, text: $text)
				.textFieldStyle(.roundedBorder)
				.keyboardType(keyboardType)
				.textInputAutocapitalization(autocapitalization)
				.disableAutocorrection(true)
				.accessibilityLabel(title)
				.accessibilityHint(footer ?? "")

			if let footer {
				Text(footer)
					.font(.caption)
					.foregroundStyle(.red)
					.accessibilityHidden(true)
			}
		}
	}
}

#Preview {
	Onboarding()
}
