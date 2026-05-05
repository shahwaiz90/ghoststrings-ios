import Foundation

internal class GhostStringsApi {
    private let config: GhostStringsConfig

    init(config: GhostStringsConfig) {
        self.config = config
    }

    func fetchStrings(ifModifiedSince: String? = nil, lang: String? = null) async throws -> FetchResult {
        let language = lang ?? Locale.current.languageCode ?? "en"
        
        let urlString = config.baseUrl.trimmingCharacters(in: CharacterSet(charactersIn: "/")) + "/ota/\(config.projectId)"
        
        var components = URLComponents(string: urlString)
        components?.queryItems = [URLQueryItem(name: "lang", value: language)]
        
        guard let url = components?.url else {
            throw NSError(domain: "GhostStrings", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }

        var request = URLRequest(url: url)
        if let ifModifiedSince = ifModifiedSince {
            request.setValue(ifModifiedSince, forHTTPHeaderField: "If-Modified-Since")
        }

        if config.debugMode {
            print("GhostStrings: [Request] GET \(url.absoluteString)")
            if let ims = ifModifiedSince {
                print("GhostStrings: [Header] If-Modified-Since: \(ims)")
            }
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "GhostStrings", code: 500, userInfo: [NSLocalizedDescriptionKey: "Server error"])
        }

        if config.debugMode {
            print("GhostStrings: [Response] Status: \(httpResponse.statusCode)")
        }

        if httpResponse.statusCode == 304 {
            return FetchResult(isModified: false)
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "GhostStrings", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server error"])
        }

        let strings = try JSONDecoder().decode([String: String].self, from: data)
        let lastModified = httpResponse.allHeaderFields["Last-Modified"] as? String
        
        return FetchResult(isModified: true, strings: strings, lastModified: lastModified)
    }
}

internal struct FetchResult {
    let isModified: Bool
    var strings: [String: String]? = nil
    var lastModified: String? = nil
}
