import Foundation

public struct GhostStringsConfig {
    public let projectId: String
    public let baseUrl: String
    public let refreshIntervalSeconds: TimeInterval
    public let debugMode: Bool

    public init(
        projectId: String,
        baseUrl: String = "https://ghoststrings.com/api/",
        refreshIntervalSeconds: TimeInterval = 3600,
        debugMode: Bool = false
    ) {
        self.projectId = projectId
        self.baseUrl = baseUrl
        self.refreshIntervalSeconds = refreshIntervalSeconds
        self.debugMode = debugMode
    }
}
