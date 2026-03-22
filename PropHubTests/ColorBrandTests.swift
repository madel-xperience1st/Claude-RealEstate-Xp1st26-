import XCTest
import SwiftUI
@testable import PropHub

final class ColorBrandTests: XCTestCase {

    func testHexInitialization6Char() {
        let color = Color(hex: "#FF0000")
        // Color should be created without crashing
        XCTAssertNotNil(color)
    }

    func testHexInitialization3Char() {
        let color = Color(hex: "F00")
        XCTAssertNotNil(color)
    }

    func testHexInitializationWithoutHash() {
        let color = Color(hex: "1B4D8E")
        XCTAssertNotNil(color)
    }

    func testSafeArraySubscript() {
        let array = [1, 2, 3]
        XCTAssertEqual(array[safe: 0], 1)
        XCTAssertEqual(array[safe: 2], 3)
        XCTAssertNil(array[safe: 5])
        XCTAssertNil(array[safe: -1])
    }
}
