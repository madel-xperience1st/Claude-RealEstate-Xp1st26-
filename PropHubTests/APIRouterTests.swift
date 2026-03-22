import XCTest
@testable import PropHub

final class APIRouterTests: XCTestCase {

    private let baseURL = "https://test.api.com/api/v1"

    func testAuthTokenEndpoint() {
        let router = APIRouter.authToken(googleIdToken: "test-token", orgId: "org-123")
        let request = router.urlRequest(baseURL: baseURL)

        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.url?.path, "/api/v1/auth/token")
        XCTAssertNotNil(request.httpBody)
    }

    func testListProjectsEndpoint() {
        let router = APIRouter.listProjects
        let request = router.urlRequest(baseURL: baseURL)

        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.url?.path, "/api/v1/projects")
        XCTAssertNil(request.httpBody)
    }

    func testListUnitsWithQueryParams() {
        let router = APIRouter.listUnits(projectId: "proj-1", contactId: "contact-1", status: "delivered")
        let request = router.urlRequest(baseURL: baseURL)

        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertTrue(request.url?.absoluteString.contains("contactId=contact-1") ?? false)
        XCTAssertTrue(request.url?.absoluteString.contains("status=delivered") ?? false)
    }

    func testUnitDetailEndpoint() {
        let router = APIRouter.unitDetail(unitId: "unit-123")
        let request = router.urlRequest(baseURL: baseURL)

        XCTAssertEqual(request.url?.path, "/api/v1/units/unit-123")
    }

    func testCreateServiceRequestEndpoint() {
        let body = ServiceRequestBody(
            category: "Plumbing",
            subject: "Leak",
            description: "Kitchen leak",
            preferredDate: nil,
            assetId: nil
        )
        let router = APIRouter.createServiceRequest(unitId: "unit-1", body: body)
        let request = router.urlRequest(baseURL: baseURL)

        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertNotNil(request.httpBody)
    }

    func testChatSessionEndpoints() {
        let create = APIRouter.createChatSession(contactId: "c1", projectId: "p1", unitId: nil)
        XCTAssertEqual(create.method, "POST")

        let send = APIRouter.sendChatMessage(sessionId: "s1", text: "hello", quickReplyValue: nil)
        XCTAssertEqual(send.method, "POST")

        let end = APIRouter.endChatSession(sessionId: "s1")
        XCTAssertEqual(end.method, "DELETE")
    }

    func testUserAgentHeader() {
        let router = APIRouter.listProjects
        let request = router.urlRequest(baseURL: baseURL)
        let userAgent = request.value(forHTTPHeaderField: "User-Agent")

        XCTAssertNotNil(userAgent)
        XCTAssertTrue(userAgent?.starts(with: "PropHub-iOS/") ?? false)
    }
}
