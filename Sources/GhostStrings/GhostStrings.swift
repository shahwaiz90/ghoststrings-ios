import Foundation
import Combine

extension Notification.Name {
    public static let GhostStringsDidUpdate = Notification.Name("GhostStringsDidUpdate")
}

/// The main entry point for the GhostStrings iOS SDK.
/// This class handles initialization, cloud synchronization, and string management.
public class GhostStrings: ObservableObject {
    /// The shared singleton instance.
    public static let shared = GhostStrings()
    
    /// The current set of strings fetched from the cloud.
    @MainActor @Published public private(set) var strings: [String: String] = [:]
    private var threadSafeStrings: [String: String] = [:]
    private let lock = NSLock()
    
    private var config: GhostStringsConfig?
    private var api: GhostStringsApi?
    private let repository = GhostStringsRepository()
    
    /// Returns true if this is the first time the SDK has been launched on this device.
    public private(set) var isFirstLaunch: Bool = false
    
    private init() {}
    
    /// Initializes the SDK with the provided configuration.
    /// - Parameters:
    ///   - config: The configuration object containing projectId and baseUrl.
    ///   - swizzle: If true, the SDK will automatically intercept native localization calls. Defaults to true.
    public func initSDK(config: GhostStringsConfig, swizzle: Bool = true) {
        self.config = config
        self.api = GhostStringsApi(config: config)
        
        // Load from cache
        let cachedStrings = repository.getStrings()
        self.updateStrings(cachedStrings)
        
        // Detect first launch
        self.isFirstLaunch = cachedStrings.isEmpty
        
        if swizzle {
            Bundle.swizzleLocalization()
        }
        
        // Sync on launch
        Task {
            await sync()
        }
    }
    
    private func updateStrings(_ newStrings: [String: String]) {
        lock.lock()
        self.threadSafeStrings = newStrings
        lock.unlock()
        
        Task { @MainActor in
            self.strings = newStrings
            NotificationCenter.default.post(name: .GhostStringsDidUpdate, object: nil)
        }
    }

    /// Internal sync access for swizzling
    func getSyncInternal(_ key: String) -> String? {
        lock.lock()
        defer { lock.unlock() }
        return threadSafeStrings[key]
    }

    public func get(_ key: String, _ defaultValue: String) -> String {
        lock.lock()
        defer { lock.unlock() }
        return threadSafeStrings[key] ?? defaultValue
    }
    
    /// Synchronizes the local strings with the GhostStrings cloud.
    /// This method is called automatically on initialization, but can be triggered manually.
    public func sync() async {
        guard let api = api else { return }
        
        do {
            let lastModified = repository.getLastModified()
            let result = try await api.fetchStrings(ifModifiedSince: lastModified)
            
            if result.isModified, let newStrings = result.strings {
                // Update memory and cache
                self.updateStrings(newStrings)
                self.repository.saveStrings(newStrings, lastModified: result.lastModified)
                self.trackEvent("ghost_sync_success")
            } else {
                // 304 Not Modified — just update sync timestamp
                self.repository.saveStrings(self.threadSafeStrings, lastModified: lastModified)
                self.trackEvent("ghost_sync_cached")
            }
            
        } catch {
            if config?.debugMode == true {
                print("GhostStrings: Sync failed - \(error)")
            }
        }
    }
    
    private func syncIfNeeded() {
        guard let config = config else { return }
        
        let lastSync = repository.getLastSyncTime()
        let now = Date().timeIntervalSince1970
        
        if now - lastSync > config.refreshIntervalSeconds {
            Task {
                await sync()
            }
        }
    }
    
    private func trackEvent(_ eventName: String) {
        let cid = repository.getLastModified()?.hashValue.description ?? UUID().uuidString
        let pid = config?.projectId ?? "unknown"
        let urlString = "https://www.google-analytics.com/g/collect?v=2&tid=G-8RCWG09F1R&cid=\(cid)&en=\(eventName)&ep.project_id=\(pid)"
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url).resume()
    }
}
