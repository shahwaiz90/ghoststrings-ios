# GhostStrings iOS SDK

A lightweight iOS SDK for Over-the-Air (OTA) translations, mirroring the GhostStrings Android functionality.

## Installation

### Swift Package Manager (SPM)

1. In Xcode, go to **File** > **Add Packages...**
2. Enter the URL of your GitHub repository.
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
            apiKey: "YOUR_API_KEY",
            baseUrl: "https://your-server.com/api/",
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

### 2. Use in SwiftUI

Use the `GhostText` view to automatically handle OTA updates:

```swift
import SwiftUI
import GhostStrings

struct ContentView: View {
    var body: some View {
        VStack {
            // This will show the value from the server if available, 
            // otherwise "Welcome Guest"
            GhostText("welcome_title", default: "Welcome Guest")
                .font(.largeTitle)
            
            Text(ghostString("subtitle", default: "Start exploring"))
        }
    }
}
```

## How to Publish

1. Push this `GhostStrings-iOS` folder to a new GitHub repository (or as a subfolder in your existing repo).
2. Go to **Releases** on GitHub and create a new tag (e.g., `1.0.0`).
3. That's it! SPM will now be able to find and install your library.

## API Parity with Android

- [x] Singleton `GhostStrings.shared`
- [x] Persistence using `UserDefaults` (matches `SharedPreferences`)
- [x] Stale-while-revalidate sync strategy
- [x] Automatic first-launch application
- [x] SwiftUI support (matches `Compose`)
