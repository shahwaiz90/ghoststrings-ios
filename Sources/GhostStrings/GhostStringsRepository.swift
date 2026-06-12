import Foundation

internal class GhostStringsRepository {
    private let defaults = UserDefaults.standard
    private let stringsKey = "com.ghoststrings.cached_strings"
    private let syncTimeKey = "com.ghoststrings.last_sync_time"

    private let lastModifiedKey = "com.ghoststrings.last_modified"
    private let languagesKey = "com.ghoststrings.cached_languages"
    private let languagesLastModifiedKey = "com.ghoststrings.languages_last_modified"

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

    func saveLanguages(_ languages: [GhostLanguage], lastModified: String?) {
        if let data = try? JSONEncoder().encode(languages) {
            defaults.set(data, forKey: languagesKey)
        }
        if let lastModified = lastModified {
            defaults.set(lastModified, forKey: languagesLastModifiedKey)
        }
    }

    func getLanguages() -> [GhostLanguage] {
        guard let data = defaults.data(forKey: languagesKey) else { return [] }
        return (try? JSONDecoder().decode([GhostLanguage].self, from: data)) ?? []
    }

    func getLanguagesLastModified() -> String? {
        return defaults.string(forKey: languagesLastModifiedKey)
    }
}
