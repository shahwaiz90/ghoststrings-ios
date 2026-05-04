import SwiftUI

public struct GhostText: View {
    @ObservedObject private var gs = GhostStrings.shared
    private let key: String
    
    public init(_ key: String) {
        self.key = key
    }
    
    public var body: some View {
        // Automatically falls back to NSLocalizedString if not in cloud
        Text(gs.get(key, NSLocalizedString(key, comment: "")))
    }
}

/// Convenience helper for string-only usage
public func ghostString(_ key: String) -> String {
    return GhostStrings.shared.get(key, NSLocalizedString(key, comment: ""))
}
