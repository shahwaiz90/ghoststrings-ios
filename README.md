# GhostStrings iOS SDK

[![Swift 6.0](https://img.shields.io/badge/Swift-6.0-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS-blue.svg?style=flat)](https://developer.apple.com/ios/)
[![Build Status](https://github.com/shahwaiz90/ghoststrings-ios/actions/workflows/swift.yml/badge.svg)](https://github.com/shahwaiz90/ghoststrings-ios/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A lightweight, zero-dependency iOS SDK for Over-the-Air (OTA) translations. Manage your app content instantly without re-submitting to the App Store.

## Features

- ⚡️ **Instant Updates**: Sync strings and translations in real-time.
- 👻 **Invisible Mode**: Use native `Text()` and `NSLocalizedString()` with zero code changes.
- 📦 **1KB Core**: Minimal footprint, maximum performance.
- 🧵 **Thread Safe**: Fully Swift 6 Concurrency compliant.
- 🛡️ **Offline First**: Stale-while-revalidate caching logic.
- 🧩 **SwiftUI Native**: Easy-to-use `GhostText` components.

## Installation

### Swift Package Manager (SPM)

1. In Xcode, go to **File** > **Add Packages...**
2. Paste the URL: `https://github.com/shahwaiz90/ghoststrings-ios`
3. Select **Up to Next Major Version** and click **Add Package**.

## Usage

### 1. Initialize the SDK

In your `App` struct or `AppDelegate`:

```swift
import GhostStrings

@main
struct MyApp: App {
    init() {
        GhostStrings.shared.initSDK(config: GhostStringsConfig(
            apiKey: "your_project_key",
            baseUrl: "https://ghoststrings-787748748049.us-central1.run.app",
            debugMode: true
        ))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### 2. Use Native Components (Invisible Mode)

Because GhostStrings swizzles the native localization system, you can use standard SwiftUI or UIKit components without any changes:

```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            // This now automatically pulls from GhostStrings!
            Text("welcome_title")
                .font(.largeTitle)
        }
    }
}
```

### 3. Use GhostText (Reactive Mode)

If you need the UI to update **instantly** without a view reload when a sync completes:

```swift
GhostText("welcome_title", default: "Welcome Guest")
```

## Pull to Refresh

To allow users to manually fetch the latest content:

```swift
ScrollView {
    // Content
}
.refreshable {
    await GhostStrings.shared.sync()
}
```

## License

GhostStrings is available under the MIT license. See the LICENSE file for more info.
