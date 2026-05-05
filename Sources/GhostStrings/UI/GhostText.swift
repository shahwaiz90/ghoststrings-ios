import SwiftUI

public struct GhostText: View {
    @ObservedObject private var gs = GhostStrings.shared
    private let key: String
    private let defaultVal: String?
    
    public init(_ key: String, default defaultVal: String? = nil) {
        self.key = key
        self.defaultVal = defaultVal
    }
    
    public var body: some View {
        // Automatically falls back to provided default OR NSLocalizedString if not in cloud
        Text(gs.get(key, defaultVal ?? NSLocalizedString(key, comment: "")))
    }
}

/// Convenience helper for string-only usage
public func ghostString(_ key: String, default defaultVal: String? = nil) -> String {
    return GhostStrings.shared.get(key, defaultVal ?? NSLocalizedString(key, comment: ""))
}
