import XCTest
@testable import PropHub

final class DemoSwitcherViewModelTests: XCTestCase {

    @MainActor
    func testInitialState() {
        let viewModel = DemoSwitcherViewModel()
        XCTAssertTrue(viewModel.projects.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
    }
}
