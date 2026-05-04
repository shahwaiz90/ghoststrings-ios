import Foundation

internal class GhostStringsApi {
    private let config: GhostStringsConfig

    init(config: GhostStringsConfig) {
        self.config = config
    }

    func fetchStrings(lang: String? = nil) async throws -> [String: String] {
        let language = lang ?? Locale.current.languageCode ?? "en"
        
        var urlString = config.baseUrl.trimmingCharacters(in: CharacterSet(charactersIn: "/")) + "/ota/\(config.apiKey)"
        
        var components = URLComponents(string: urlString)
        components?.queryItems = [URLQueryItem(name: "lang", value: language)]
        
        guard let url = components?.url else {
            throw NSError(domain: "GhostStrings", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }

        if config.debugMode {
            print("GhostStrings: Fetching from \(url.absoluteString)")
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "GhostStrings", code: 500, userInfo: [NSLocalizedDescriptionKey: "Server error"])
        }

        let strings = try JSONDecoder().decode([String: String].self, from: data)
        return strings
    }
}
