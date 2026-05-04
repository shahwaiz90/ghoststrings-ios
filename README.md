# GhostStrings iOS SDK

[![Build Status](https://github.com/shahwaiz90/ghoststrings-ios/actions/workflows/swift.yml/badge.svg)](https://github.com/shahwaiz90/ghoststrings-ios/actions)
[![Swift Package Index](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fshahwaiz90%2Fghoststrings-ios%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/shahwaiz90/ghoststrings-ios)
[![Swift 6.0](https://img.shields.io/badge/Swift-6.0-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A lightweight, zero-dependency iOS SDK for Over-the-Air (OTA) translations. Manage your app content instantly without re-submitting to the App Store.

## Features

- ⚡️ **Instant Updates**: Sync strings and translations in real-time.
- 👻 **Invisible Mode**: Use native `Text()` and `NSLocalizedString()` with zero code changes.
- 📦 **1KB Core**: Minimal footprint, maximum performance.
- 🧵 **Thread Safe**: Fully Swift 6 Concurrency compliant.
- 🛡️ **Offline First**: Stale-while-revalidate caching logic.

## Installation

### Swift Package Manager (SPM)

1. In Xcode, go to **File** > **Add Packages...**
2. Paste the URL: `https://github.com/shahwaiz90/ghoststrings-ios`
3. Select **Up to Next Major Version** and click **Add Package**.

## Usage

### 1. Initialize the SDK

```swift
import GhostStrings

@main
struct MyApp: App {
    init() {
        GhostStrings.shared.initSDK(config: GhostStringsConfig(
            apiKey: "your_project_key",
            baseUrl: "https://your-server.com/api/"
        ))
    }
}
```

### 2. Pick Your Integration Mode

| Mode | Usage | Best For |
| :--- | :--- | :--- |
| **Invisible** | `Text("welcome_key")` | Legacy projects & standard native feeling. |
| **Reactive** | `GhostText("welcome_key")` | Real-time updates while the user is on-screen. |

#### Invisible Mode (Standard SwiftUI)
Because GhostStrings swizzles the native localization system, you can use standard SwiftUI components without any changes:

```swift
// This automatically pulls from the cloud!
Text("welcome_title")
```

#### Reactive Mode (GhostText)
Use `GhostText` if you want the UI to update **instantly** without a view reload when a background sync completes:

```swift
GhostText("welcome_title")
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
