import Foundation

public struct GhostLanguage: Codable, Equatable {
    public let localeId: String
    public let label: String

    public init(localeId: String, label: String) {
        self.localeId = localeId
        self.label = label
    }
}
