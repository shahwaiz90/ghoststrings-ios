import XCTest
@testable import GhostStrings

final class GhostStringsTests: XCTestCase {
    func testLiveSync() async throws {
        let config = GhostStringsConfig(
            apiKey: "dk_5c22c59fc93e46e588fecb22",
            baseUrl: "https://ghoststrings-787748748049.us-central1.run.app",
            debugMode: true
        )
        
        await GhostStrings.shared.initSDK(config: config)
        await GhostStrings.shared.sync()
        
        let title = await GhostStrings.shared.get("hero_title", "Fallback")
        print("\nFetched Title: \(title)\n")
        
        // Assert that we got something other than the fallback (assuming the server has data)
        XCTAssertNotEqual(title, "Fallback")
    }
}
