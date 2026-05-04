import Foundation
import Combine

@MainActor
public class GhostStrings: ObservableObject {
    public static let shared = GhostStrings()
    
    @Published private(set) var cachedStrings: [String: String] = [:]
    
    private var config: GhostStringsConfig?
    private var repository = GhostStringsRepository()
    private var api: GhostStringsApi?
    
    private var isFirstLaunch: Bool = false
    
    private init() {}
    
    public func initSDK(config: GhostStringsConfig) {
        self.config = config
        self.api = GhostStringsApi(config: config)
        
        // Load existing strings
        self.cachedStrings = repository.getStrings()
        
        // Detect first launch
        self.isFirstLaunch = cachedStrings.isEmpty
        
        // Sync on launch
        Task {
            await sync()
        }
    }
    
    public func get(_ key: String, _ defaultValue: String) -> String {
        return cachedStrings[key] ?? defaultValue
    }
    
    public func sync() async {
        guard let api = api else { return }
        
        do {
            let strings = try await api.fetchStrings()
            repository.saveStrings(strings)
            
            if isFirstLaunch {
                self.cachedStrings = strings
            }
        } catch {
            if config?.debugMode == true {
                print("GhostStrings Sync Error: \(error.localizedDescription)")
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
