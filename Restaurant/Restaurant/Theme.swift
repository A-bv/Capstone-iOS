import CoreFoundation

/// Shared spacing and corner-radius scale, so components pull from one set of
/// values instead of scattering magic numbers.
enum Spacing {
	static let small: CGFloat = 8
	static let medium: CGFloat = 12
	static let large: CGFloat = 16
}

enum CornerRadius {
	static let small: CGFloat = 8
	static let medium: CGFloat = 12
}
