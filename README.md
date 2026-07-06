# Little Lemon (iOS)

A modern restaurant app built with SwiftUI: sign up, browse the menu, and search it live. Capstone project in the Little Lemon series — see the [web](https://github.com/A-bv/Capstone-react) and [React Native](https://github.com/A-bv/Capstone-react-native) versions.

[![CI](https://github.com/A-bv/Capstone-iOS/actions/workflows/ci.yml/badge.svg)](https://github.com/A-bv/Capstone-iOS/actions/workflows/ci.yml)
![Swift 6.0](https://img.shields.io/badge/Swift-6.0-F05138?logo=swift&logoColor=white)
![iOS 17.2+](https://img.shields.io/badge/iOS-17.2%2B-007AFF?logo=apple&logoColor=white)
![Xcode 16+](https://img.shields.io/badge/Xcode-16%2B-147EFB?logo=xcode&logoColor=white)
[![License: MIT](https://img.shields.io/badge/License-MIT-lightgrey)](LICENSE)

<p align="center">
  <img src="Screenshots/preview.gif" width="250" alt="Little Lemon app walkthrough: sign up, browse the menu, view a dish, and the profile">
</p>

## Screenshots

| Sign up | Menu |
| :--: | :--: |
| <img src="Screenshots/onboarding.jpg" width="250" alt="Little Lemon sign-up screen"> | <img src="Screenshots/menu.jpg" width="250" alt="Little Lemon menu screen"> |

## Features

- **Account creation and persistence** — create an account; the app retains the login status across launches.
- **Live menu** — fetched from an API and cached on device with Core Data, so it also loads offline.
- **Search** — a search bar filters the menu items as you type.
- **Localized** — the interface ships in English and French.

## Requirements

- iOS 17.2 or later
- Xcode 16 or later
- Swift 6

## Build & run

```bash
git clone https://github.com/A-bv/Capstone-iOS.git
cd Capstone-iOS
open Restaurant/Restaurant.xcodeproj
```

Select an iOS 17.2+ simulator (or a device) and press **⌘R** to run.

## Tests

Unit and UI tests live in `RestaurantTests` and `RestaurantUITests`; CI builds and tests every push.

```bash
xcodebuild test -scheme Restaurant \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

## Design

Two Figma wireframes (`wireframe little lemon 1.fig` and `wireframe little lemon 2.fig`) are included at the repository root.

## License

MIT. See [LICENSE](LICENSE).
