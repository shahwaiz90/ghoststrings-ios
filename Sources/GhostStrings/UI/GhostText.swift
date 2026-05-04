import SwiftUI

/// A SwiftUI View that displays a string from GhostStrings.
/// It automatically uses the OTA value if available, or falls back to the default.
public struct GhostText: View {
    private let key: String
    private let defaultValue: String
    
    @ObservedObject private var ghostStrings = GhostStrings.shared
    
    public init(_ key: String, default defaultValue: String) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    public var body: some View {
        Text(ghostStrings.get(key, defaultValue))
    }
}

/// Helper for when you need the string value directly (e.g. in an alert or picker)
public extension View {
    func ghostString(_ key: String, default defaultValue: String) -> String {
        return GhostStrings.shared.get(key, defaultValue)
    }
}
