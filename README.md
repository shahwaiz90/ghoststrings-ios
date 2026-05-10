# GhostStrings iOS SDK 👻🍏

The "Invisible String" for your iOS apps. GhostStrings allows you to update your app's content Over-the-Air (OTA) with zero code changes, using standard Apple localization patterns.

## 🚀 Features

- **Zero-Code Swizzling**: Automatically intercepts `NSLocalizedString` calls via `Bundle` swizzling.
- **SwiftUI Ready**: Includes `GhostStringsProvider` for automatic, seamless UI refreshes.
- **Objective-C & Swift**: Works perfectly with both languages and all Apple UI frameworks.
- **Offline First**: robust local caching ensures strings are always available even without internet.

## 📦 Installation

### Swift Package Manager (SPM)

1. In Xcode, go to **File > Add Packages...**
2. Enter the repository URL: `https://github.com/shahwaiz90/ghoststrings-ios`
3. Select the version (at least `1.1.3` for auto-refresh support).

## 🛠️ Usage

### 1. Initialize the SDK

In your `App` or `AppDelegate`:

```swift
import GhostStrings

@main
struct MyApp: App {
    init() {
        GhostStrings.shared.initSDK(config: GhostStringsConfig(
            projectId: "YOUR_PROJECT_ID",
            baseUrl: "https://api.ghoststrings.ai",
            debugMode: true
        ))
    }
    
    var body: some Scene {
        WindowGroup {
            // Use the Provider for automatic OTA refreshes
            GhostStringsProvider {
                ContentView()
            }
        }
    }
}
```

### 2. Native Integration

Just use standard iOS localization methods. GhostStrings intercepts these automatically!

#### SwiftUI
```swift
Text(NSLocalizedString("hero_title", 
                       value: "The Invisible String.", // Native fallback
                       comment: ""))
```

#### Objective-C
```objectivec
UILabel *label = [[UILabel alloc] init];
label.text = NSLocalizedString(@"hero_title", @"comment");
```

## 🔄 Automatic Refresh
By wrapping your root view in `GhostStringsProvider`, any changes you make in the GhostStrings dashboard will appear **instantly** in the app as soon as the sync completes—no code required in your subviews!

## 📄 License
MIT License
