import Foundation

public struct GhostStringsConfig {
    public let projectId: String
    public let baseUrl: String
    public let refreshIntervalSeconds: TimeInterval
    public let debugMode: Bool
    public let enableAnimations: Bool

    public init(
        projectId: String,
        baseUrl: String = "https://api.ghoststrings.ai",
        refreshIntervalSeconds: TimeInterval = 3600,
        debugMode: Bool = false,
        enableAnimations: Bool = true
    ) {
        self.projectId = projectId
        self.baseUrl = baseUrl
        self.refreshIntervalSeconds = refreshIntervalSeconds
        self.debugMode = debugMode
        self.enableAnimations = enableAnimations
    }
}
