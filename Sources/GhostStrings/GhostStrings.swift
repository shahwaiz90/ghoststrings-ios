import Foundation
import Combine
import SwiftUI

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
    
    private var lastModified: String?
    
    private var config: GhostStringsConfig?
    private var api: GhostStringsApi?
    private let repository = GhostStringsRepository()
    
    /// Returns true if this is the first time the SDK has been launched on this device.
    public private(set) var isFirstLaunch: Bool = false
    
    private var activeLanguage: String?

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
        self.lastModified = repository.getLastModified()
        self.updateStrings(cachedStrings)
        
        // Detect first launch
        self.isFirstLaunch = cachedStrings.isEmpty
        
        if swizzle {
            Bundle.swizzleLocalization()
        }
        
        // Sync once on startup (will return 304 if content is unchanged)
        Task { await sync() }
        
        trackEvent("ghost_app_identified")
    }
    
    private func updateStrings(_ newStrings: [String: String]) {
        lock.lock()
        self.threadSafeStrings = newStrings
        lock.unlock()
        
        Task { @MainActor in
            if self.config?.enableAnimations == true {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    self.strings = newStrings
                }
            } else {
                self.strings = newStrings
            }
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

    // ── Language Switching API ───────────────────────────────────────────────

    public func setLanguage(_ lang: String?, onComplete: ((Bool) -> Void)? = nil) {
        let targetLang = (lang?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true) ? nil : lang
        self.activeLanguage = targetLang

        // Reset lastModified timestamp when changing language to ensure fresh fetch if no cache
        self.lastModified = nil

        // Trigger sync
        Task {
            let success = await sync(force: true)
            onComplete?(success)
        }
    }

    public func getLanguage() -> String? {
        return activeLanguage
    }

    /// Fetches the supported languages list dynamically from the server.
    /// Uses local caching and background revalidation (stale-while-revalidate).
    public func getSupportedLanguages(force: Bool = false) async -> [GhostLanguage] {
        guard let api = api else { return [] }
        let cachedLangs = repository.getLanguages()

        if cachedLangs.isEmpty || force {
            do {
                let result = try await api.fetchLanguages(ifModifiedSince: force ? nil : repository.getLanguagesLastModified())
                if result.isModified, let fetchedLangs = result.languages {
                    repository.saveLanguages(fetchedLangs, lastModified: result.lastModified)
                    return fetchedLangs
                } else if !result.isModified {
                    return cachedLangs
                }
            } catch {
                // Return cached fallback on failure
                return cachedLangs
            }
        } else {
            // Background update (stale-while-revalidate)
            Task {
                do {
                    let result = try await api.fetchLanguages(ifModifiedSince: repository.getLanguagesLastModified())
                    if result.isModified, let fetchedLangs = result.languages {
                        repository.saveLanguages(fetchedLangs, lastModified: result.lastModified)
                    }
                } catch {
                    // Ignore background errors
                }
            }
        }

        return cachedLangs
    }

    /// Callback-friendly version of getSupportedLanguages for Objective-C / Swift non-async callers.
    public func getSupportedLanguages(force: Bool = false, onComplete: @escaping ([GhostLanguage]) -> Void) {
        Task {
            let langs = await getSupportedLanguages(force: force)
            onComplete(langs)
        }
    }
    
    /// Synchronizes the local strings with the GhostStrings cloud.
    /// This method is called automatically on initialization, but can be triggered manually.
    @discardableResult
    public func sync(force: Bool = false) async -> Bool {
        return await sync(force: force, lang: activeLanguage)
    }

    @discardableResult
    public func sync(force: Bool, lang: String?) async -> Bool {
        guard let api = api else { return false }
        
        do {
            let result = try await api.fetchStrings(ifModifiedSince: force ? nil : lastModified, lang: lang)
            
            if result.isModified, let newStrings = result.strings {
                if config?.debugMode == true { print("GhostStrings: New OTA content applied successfully.") }
                self.lastModified = result.lastModified
                // Update memory and cache
                self.updateStrings(newStrings)
                self.repository.saveStrings(newStrings, lastModified: result.lastModified)
                self.trackEvent("ghost_sync_success")
                return true
            } else {
                if config?.debugMode == true { print("GhostStrings: Content is up-to-date (304). No update needed.") }
                // 304 Not Modified — just update sync timestamp
                self.repository.saveStrings(self.threadSafeStrings, lastModified: lastModified)
                self.trackEvent("ghost_sync_cached")
                return true
            }
            
        } catch {
            if config?.debugMode == true {
                print("GhostStrings: Sync failed - \(error)")
            }
            return false
        }
    }
    
    private func trackEvent(_ eventName: String) {
        let cid = repository.getLastModified()?.hashValue.description ?? UUID().uuidString
        let pid = config?.projectId ?? "unknown"
        
        // Get App Metadata
        let appId = Bundle.main.bundleIdentifier ?? "unknown"
        let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "unknown"
        
        let urlString = "https://www.google-analytics.com/g/collect?v=2&tid=G-8RCWG09F1R&cid=\(cid)&en=\(eventName)" +
                        "&ep.project_id=\(pid)&ep.app_id=\(appId)&ep.app_name=\(appName)&ep.platform=ios"
        
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? urlString) else { return }
        
        URLSession.shared.dataTask(with: url).resume()
    }
}

// ─── String Extension for Developer Convenience ─────────────────────────────
extension String {
    /// Shorthand to get a localized string from GhostStrings.
    /// Example: Text("hero_title".gs)
    public var gs: String {
        return GhostStrings.shared.get(self, NSLocalizedString(self, comment: ""))
    }
}
