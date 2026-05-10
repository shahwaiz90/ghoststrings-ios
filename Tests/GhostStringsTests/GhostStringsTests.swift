import XCTest
@testable import GhostStrings

final class GhostStringsTests: XCTestCase {
    func testLiveSync() async throws {
        let config = GhostStringsConfig(
            projectId: "dk_5c22c59fc93e46e588fecb22",
            baseUrl: "https://ghoststrings.ai",
            debugMode: true
        )
        
        GhostStrings.shared.initSDK(config: config)
        await GhostStrings.shared.sync()
        
        let title = GhostStrings.shared.get("hero_title", "Fallback")
        print("\nFetched Title: \(title)\n")
        
        XCTAssertNotEqual(title, "Fallback")
    }
    
    func testConfigInitialization() {
        let config = GhostStringsConfig(projectId: "test_key", debugMode: true)
        XCTAssertEqual(config.projectId, "test_key")
        XCTAssertTrue(config.debugMode)
        XCTAssertEqual(config.baseUrl, "https://api.ghoststrings.ai") // Default
    }
    
    func testFallbackLogic() async {
        let config = GhostStringsConfig(projectId: "test_key")
        GhostStrings.shared.initSDK(config: config)
        
        let value = GhostStrings.shared.get("non_existent_key", "Default Value")
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
