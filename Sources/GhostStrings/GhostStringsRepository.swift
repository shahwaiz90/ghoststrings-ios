import Foundation

internal class GhostStringsRepository {
    private let defaults = UserDefaults.standard
    private let stringsKey = "com.ghoststrings.cached_strings"
    private let syncTimeKey = "com.ghoststrings.last_sync_time"

    private let lastModifiedKey = "com.ghoststrings.last_modified"

    func saveStrings(_ strings: [String: String], lastModified: String? = nil) {
        defaults.set(strings, forKey: stringsKey)
        defaults.set(Date().timeIntervalSince1970, forKey: syncTimeKey)
        if let lastModified = lastModified {
            defaults.set(lastModified, forKey: lastModifiedKey)
        }
    }

    func getStrings() -> [String: String] {
        return defaults.dictionary(forKey: stringsKey) as? [String: String] ?? [:]
    }

    func getLastSyncTime() -> TimeInterval {
        return defaults.double(forKey: syncTimeKey)
    }

    func getLastModified() -> String? {
        return defaults.string(forKey: lastModifiedKey)
    }
}
