import SwiftUI

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

extension ShapeStyle where Self == Color {
	/// A muted secondary text color that, unlike the system `.secondary`,
	/// clears the 4.5:1 WCAG contrast bar for small text in light and dark.
	static var readableSecondary: Color { .primary.opacity(0.6) }
}
