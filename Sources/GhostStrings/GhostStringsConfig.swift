import Foundation

public struct GhostStringsConfig {
    public let apiKey: String
    public let baseUrl: String
    public let refreshIntervalSeconds: TimeInterval
    public let debugMode: Bool

    public init(
        apiKey: String,
        baseUrl: String = "https://ghoststrings.com/api/",
        refreshIntervalSeconds: TimeInterval = 3600,
        debugMode: Bool = false
    ) {
        self.apiKey = apiKey
        self.baseUrl = baseUrl
        self.refreshIntervalSeconds = refreshIntervalSeconds
        self.debugMode = debugMode
    }
}
