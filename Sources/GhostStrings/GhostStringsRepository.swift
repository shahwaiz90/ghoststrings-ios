import Foundation

internal class GhostStringsRepository {
    private let defaults = UserDefaults.standard
    private let stringsKey = "com.ghoststrings.cached_strings"
    private let syncTimeKey = "com.ghoststrings.last_sync_time"

    func saveStrings(_ strings: [String: String]) {
        defaults.set(strings, forKey: stringsKey)
        defaults.set(Date().timeIntervalSince1970, forKey: syncTimeKey)
    }

    func getStrings() -> [String: String] {
        return defaults.dictionary(forKey: stringsKey) as? [String: String] ?? [:]
    }

    func getLastSyncTime() -> TimeInterval {
        return defaults.double(forKey: syncTimeKey)
    }
}
