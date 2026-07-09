# Little Lemon (iOS)

The iOS build of the Little Lemon capstone: sign up, browse a live menu, and filter or search it — in English or French. See also the [web](https://github.com/A-bv/Capstone-react) and [React Native](https://github.com/A-bv/Capstone-react-native) versions.

[![CI](https://github.com/A-bv/Capstone-iOS/actions/workflows/ci.yml/badge.svg)](https://github.com/A-bv/Capstone-iOS/actions/workflows/ci.yml)
![Swift 6.0](https://img.shields.io/badge/Swift-6.0-F05138?logo=swift&logoColor=white)
![iOS 17.2+](https://img.shields.io/badge/iOS-17.2%2B-007AFF?logo=apple&logoColor=white)
![SwiftUI](https://img.shields.io/badge/SwiftUI-0071e3?logo=swift&logoColor=white)
[![License: MIT](https://img.shields.io/badge/License-MIT-lightgrey)](LICENSE)

The menu is fetched from an API and cached on device with Core Data, so it loads instantly and works offline. Accounts persist across launches, the menu filters by category and searches live, and the whole interface is localized in English and French.

## Screenshots

| Sign up | Menu |
| :--: | :--: |
| <img src="Screenshots/onboarding.jpg" width="250" alt="Little Lemon sign-up screen"> | <img src="Screenshots/menu.jpg" width="250" alt="Little Lemon menu screen"> |

<p align="center">
  <img src="Screenshots/preview.gif" width="250" alt="Little Lemon app walkthrough: sign up, browse the menu, view a dish, and the profile">
</p>

## Engineering

A capstone built to a senior iOS bar — the interesting parts are under the hood.

**Modern Swift & concurrency**
- Swift 6 language mode (strict concurrency), clean.
- The view model is isolated to `@MainActor`; networking is structured `async/await`.
- The in-flight menu download is cancelled when the screen disappears, and a transient network error retries once behind a short request timeout.

**Architecture & testability**
- MVVM with the `@Observable` macro and a single source of truth for the menu and its filter state.
- The network fetch and the Core Data store are injectable seams, so the view model is unit-tested with canned data and an in-memory store — no simulator, no network.

**Production quality**
- The on-device cache self-heals: a corrupt or un-migratable store is logged, destroyed, and rebuilt, because the menu is re-downloadable.
- A privacy manifest declares the one required-reason API in use (`UserDefaults`); failures are reported through `os.Logger`.
- Selection and success haptics, animated filtering, and a shared spacing/radius scale instead of per-view magic numbers.

**Accessibility & localization**
- VoiceOver labels and traits, menu and profile rows grouped into single elements, decorative images hidden.
- Dynamic Type up to the largest accessibility sizes, with a header that grows instead of clipping.
- Full English and French through a String Catalog, including the data-driven category names.

**Tests & tooling**
- Unit tests cover the view-model logic, JSON decoding, load cancellation, and the retry — and a re-entrant "load twice" bug is pinned by a negative control.
- A UI test walks sign-up → menu → profile through the running app.
- GitHub Actions builds and runs all of it on every push.

## Architecture

SwiftUI views observe a `@MainActor @Observable` view model that owns the menu and filter state and talks to two seams — a fetch closure and a Core Data store. Views stay declarative; every mutation flows through the model on the main actor. Login state lives in `@AppStorage` at the app root, which swaps between onboarding and the tab bar.

## Build & run

```bash
git clone https://github.com/A-bv/Capstone-iOS.git
cd Capstone-iOS
open Restaurant/Restaurant.xcodeproj
```

Select an iOS 17.2+ simulator (or a device) and press **⌘R**.

```bash
xcodebuild test -scheme Restaurant \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

## Design

Two Figma wireframes (`wireframe little lemon 1.fig` and `wireframe little lemon 2.fig`) are included at the repository root.

## Author

Built by [A-bv](https://github.com/A-bv).

## License

MIT. See [LICENSE](LICENSE).
