import XCTest
@testable import PropHub

final class CacheManagerTests: XCTestCase {

    override func tearDown() {
        super.tearDown()
        CacheManager.shared.clearAll()
    }

    func testStoreAndRetrieve() {
        let testData = TestModel(id: "1", name: "Test")
        CacheManager.shared.store(testData, forKey: "test.key")

        let retrieved = CacheManager.shared.retrieve(forKey: "test.key", as: TestModel.self)
        XCTAssertEqual(retrieved?.id, "1")
        XCTAssertEqual(retrieved?.name, "Test")
    }

    func testRetrieveNonExistent() {
        let result = CacheManager.shared.retrieve(forKey: "nonexistent", as: TestModel.self)
        XCTAssertNil(result)
    }

    func testClearAll() {
        let testData = TestModel(id: "1", name: "Test")
        CacheManager.shared.store(testData, forKey: "test.clear")
        CacheManager.shared.clearAll()

        let result = CacheManager.shared.retrieve(forKey: "test.clear", as: TestModel.self)
        XCTAssertNil(result)
    }

    func testRemoveSpecificKey() {
        let testData = TestModel(id: "1", name: "Test")
        CacheManager.shared.store(testData, forKey: "test.remove")
        CacheManager.shared.remove(forKey: "test.remove")

        let result = CacheManager.shared.retrieve(forKey: "test.remove", as: TestModel.self)
        XCTAssertNil(result)
    }
}

private struct TestModel: Codable, Equatable {
    let id: String
    let name: String
}
