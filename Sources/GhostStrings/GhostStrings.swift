import Foundation
import Combine

extension Notification.Name {
    public static let GhostStringsDidUpdate = Notification.Name("GhostStringsDidUpdate")
}

public class GhostStrings: ObservableObject {
    public static let shared = GhostStrings()
    
    @MainActor @Published public private(set) var strings: [String: String] = [:]
    private var threadSafeStrings: [String: String] = [:]
    private let lock = NSLock()
    
    private var config: GhostStringsConfig?
    private var api: GhostStringsApi?
    private let repository = GhostStringsRepository()
    
    public private(set) var isFirstLaunch: Bool = false
    
    private init() {}
    
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
    
    public func sync() async {
        guard let api = api else { return }
        
        do {
            let newStrings = try await api.fetchStrings()
            
            // Update memory and cache
            self.updateStrings(newStrings)
            self.repository.saveStrings(newStrings)
            
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
}
