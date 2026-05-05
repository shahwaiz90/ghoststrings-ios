import SwiftUI

public struct GhostStringsProvider<Content: View>: View {
    @ObservedObject private var gs = GhostStrings.shared
    private let content: () -> Content
    
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    public var body: some View {
        content()
            // This forces a re-render of the entire view tree when strings change
            .id(gs.strings.hashValue)
    }
}

extension View {
    /// Automatically refreshes the view when GhostStrings updates
    public func ghostStringsAutoRefresh() -> some View {
        GhostStringsProvider {
            self
        }
    }
}
