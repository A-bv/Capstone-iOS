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
	@State private var showAlert: Bool = false
	
	var body: some View {
		NavigationStack {
			VStack {
				TextField("First Name", text: $firstName)
					.padding()
					.textFieldStyle(RoundedBorderTextFieldStyle())
					.disableAutocorrection(true)
				
				TextField("Last Name", text: $lastName)
					.padding()
					.textFieldStyle(RoundedBorderTextFieldStyle())
					.disableAutocorrection(true)
				
				TextField("Email", text: $email)
					.padding()
					.textFieldStyle(RoundedBorderTextFieldStyle())
					.keyboardType(.emailAddress)
					.textInputAutocapitalization(.never)
					.disableAutocorrection(true)
				
				Button("Register") {
					if !firstName.isEmpty && !lastName.isEmpty && isValidEmail(email) {
						UserDefaults.standard.set(firstName, forKey: keyFirstName)
						UserDefaults.standard.set(lastName, forKey: keyLastName)
						UserDefaults.standard.set(email, forKey: keyEmail)
						isLoggedIn = true
					} else {
						showAlert = true
					}
				}
				.alert(isPresented: $showAlert) {
					Alert(title: Text("Invalid Entry"), message: Text("Please correct your entry"), dismissButton: .default(Text("OK")))
				}
				.padding()
				
				Spacer()
			}
			.padding()
		}
	}
	
	func isValidEmail(_ email: String) -> Bool {
		let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
		let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
		return emailTest.evaluate(with: email)
	}
}

#Preview {
	Onboarding()
}
