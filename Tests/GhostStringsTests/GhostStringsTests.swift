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
        
        XCTAssertNotEqual(title, "Fallback")
    }
    
    func testConfigInitialization() {
        let config = GhostStringsConfig(apiKey: "test_key", debugMode: true)
        XCTAssertEqual(config.apiKey, "test_key")
        XCTAssertTrue(config.debugMode)
        XCTAssertEqual(config.baseUrl, "https://ghoststrings.com/api/") // Default
    }
    
    func testFallbackLogic() async {
        let config = GhostStringsConfig(apiKey: "test_key")
        await GhostStrings.shared.initSDK(config: config)
        
        let value = await GhostStrings.shared.get("non_existent_key", "Default Value")
        XCTAssertEqual(value, "Default Value")
    }
    
    func testRepositoryStorage() {
        let repo = GhostStringsRepository()
        let testStrings = ["test_key": "test_value"]
        
        repo.saveStrings(testStrings)
        let loaded = repo.getStrings()
        
        XCTAssertEqual(loaded["test_key"], "test_value")
    }
}
