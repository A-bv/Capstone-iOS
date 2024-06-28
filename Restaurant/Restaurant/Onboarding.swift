import SwiftUI

let keyFirstName = "firstNameKey"
let keyLastName = "lastNameKey"
let keyEmail = "emailKey"
let keyIsLoggedIn = "isLoggedInKey"

struct Onboarding: View {
	@State private var firstName = ""
	@State private var lastName = ""
	@State private var email = ""
	@State private var isLoggedIn = false
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
					.autocapitalization(.none)
					.disableAutocorrection(true)
				
				Button("Register") {
					if !firstName.isEmpty && !lastName.isEmpty && isValidEmail(email) {
						UserDefaults.standard.set(firstName, forKey: keyFirstName)
						UserDefaults.standard.set(lastName, forKey: keyLastName)
						UserDefaults.standard.set(email, forKey: keyEmail)
						UserDefaults.standard.set(true, forKey: keyIsLoggedIn)
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
			.navigationDestination(isPresented: $isLoggedIn) {
				Home()
			}
			.onAppear {
				if UserDefaults.standard.bool(forKey: keyIsLoggedIn) {
					isLoggedIn = true
				}
			}
		}
	}
	
	func isValidEmail(_ email: String) -> Bool {
		let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
		let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
		return emailTest.evaluate(with: email)
	}
}

struct Onboarding_Previews: PreviewProvider {
	static var previews: some View {
		Onboarding()
	}
}
