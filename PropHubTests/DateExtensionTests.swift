import XCTest
@testable import PropHub

final class DateExtensionTests: XCTestCase {

    func testDaysFromTodayPast() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        XCTAssertEqual(yesterday.daysFromToday, -1)
    }

    func testDaysFromTodayFuture() {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        XCTAssertEqual(tomorrow.daysFromToday, 1)
    }

    func testDaysFromTodayToday() {
        XCTAssertEqual(Date().daysFromToday, 0)
    }

    func testIsPast() {
        let past = Calendar.current.date(byAdding: .hour, value: -1, to: Date())!
        XCTAssertTrue(past.isPast)

        let future = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        XCTAssertFalse(future.isPast)
    }

    func testIsWithinDays() {
        let inThreeDays = Calendar.current.date(byAdding: .day, value: 3, to: Date())!
        XCTAssertTrue(inThreeDays.isWithinDays(5))
        XCTAssertFalse(inThreeDays.isWithinDays(2))
    }

    func testMediumFormatted() {
        let date = Date()
        let formatted = date.mediumFormatted
        XCTAssertFalse(formatted.isEmpty)
    }
}
