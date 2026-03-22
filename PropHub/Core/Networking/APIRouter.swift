import Foundation

/// Defines all MuleSoft API endpoints with their HTTP methods, paths, and parameters.
/// Each case maps to a specific MuleSoft Experience API endpoint.
enum APIRouter {
    // MARK: - Auth
    case authToken(googleIdToken: String, orgId: String)
    case authRefresh
    case authLogout

    // MARK: - Projects
    case listProjects
    case projectDetail(projectId: String)

    // MARK: - Units
    case listUnits(projectId: String, contactId: String, status: String?)
    case unitDetail(unitId: String)

    // MARK: - Finance
    case installments(unitId: String)
    case invoices(unitId: String)
    case invoicePDF(unitId: String, invoiceId: String)
    case paymentSummary(unitId: String)

    // MARK: - Service Requests
    case listServiceRequests(unitId: String, status: String?)
    case createServiceRequest(unitId: String, body: ServiceRequestBody)
    case uploadAttachment(requestId: String)
    case serviceRequestDetail(requestId: String)

    // MARK: - Assets
    case listAssets(unitId: String)
    case assetDetail(assetId: String)
    case assetWarranty(assetId: String)
    case assetMaintenance(assetId: String)

    // MARK: - Chat
    case createChatSession(contactId: String, projectId: String, unitId: String?)
    case sendChatMessage(sessionId: String, text: String, quickReplyValue: String?)
    case endChatSession(sessionId: String)

    // MARK: - Notifications
    case registerPushToken(fcmToken: String, contactId: String)

    // MARK: - New Launches
    case listLaunches(projectId: String?)
    case launchDetail(launchId: String)
    case joinWaitlist(body: WaitlistBody)

    /// HTTP method for the endpoint.
    var method: String {
        switch self {
        case .authToken, .authRefresh, .authLogout,
             .createServiceRequest, .uploadAttachment,
             .createChatSession, .sendChatMessage,
             .registerPushToken, .joinWaitlist:
            return "POST"
        case .endChatSession:
            return "DELETE"
        default:
            return "GET"
        }
    }

    /// Relative path for the endpoint.
    var path: String {
        switch self {
        case .authToken:
            return "/auth/token"
        case .authRefresh:
            return "/auth/refresh"
        case .authLogout:
            return "/auth/logout"
        case .listProjects:
            return "/projects"
        case .projectDetail(let projectId):
            return "/projects/\(projectId)"
        case .listUnits(let projectId, _, _):
            return "/projects/\(projectId)/units"
        case .unitDetail(let unitId):
            return "/units/\(unitId)"
        case .installments(let unitId):
            return "/units/\(unitId)/installments"
        case .invoices(let unitId):
            return "/units/\(unitId)/invoices"
        case .invoicePDF(let unitId, let invoiceId):
            return "/units/\(unitId)/invoices/\(invoiceId)/pdf"
        case .paymentSummary(let unitId):
            return "/units/\(unitId)/payment-summary"
        case .listServiceRequests(let unitId, _):
            return "/units/\(unitId)/service-requests"
        case .createServiceRequest(let unitId, _):
            return "/units/\(unitId)/service-requests"
        case .uploadAttachment(let requestId):
            return "/service-requests/\(requestId)/attachments"
        case .serviceRequestDetail(let requestId):
            return "/service-requests/\(requestId)"
        case .listAssets(let unitId):
            return "/units/\(unitId)/assets"
        case .assetDetail(let assetId):
            return "/assets/\(assetId)"
        case .assetWarranty(let assetId):
            return "/assets/\(assetId)/warranty"
        case .assetMaintenance(let assetId):
            return "/assets/\(assetId)/maintenance"
        case .createChatSession:
            return "/chat/sessions"
        case .sendChatMessage(let sessionId, _, _):
            return "/chat/sessions/\(sessionId)/messages"
        case .endChatSession(let sessionId):
            return "/chat/sessions/\(sessionId)"
        case .registerPushToken:
            return "/notifications/register"
        case .listLaunches:
            return "/launches"
        case .launchDetail(let launchId):
            return "/launches/\(launchId)"
        case .joinWaitlist:
            return "/waitlist"
        }
    }

    /// Query parameters for GET requests.
    var queryItems: [URLQueryItem]? {
        switch self {
        case .listUnits(_, let contactId, let status):
            var items = [URLQueryItem(name: "contactId", value: contactId)]
            if let status = status {
                items.append(URLQueryItem(name: "status", value: status))
            }
            return items
        case .listServiceRequests(_, let status):
            if let status = status {
                return [URLQueryItem(name: "status", value: status)]
            }
            return nil
        case .listLaunches(let projectId):
            if let projectId = projectId {
                return [URLQueryItem(name: "projectId", value: projectId)]
            }
            return nil
        default:
            return nil
        }
    }

    /// JSON body for POST requests.
    var body: Data? {
        let encoder = JSONEncoder()
        switch self {
        case .authToken(let googleIdToken, let orgId):
            return try? encoder.encode(["googleIdToken": googleIdToken, "orgId": orgId])
        case .createServiceRequest(_, let requestBody):
            return try? encoder.encode(requestBody)
        case .createChatSession(let contactId, let projectId, let unitId):
            var dict: [String: String] = ["contactId": contactId, "projectId": projectId]
            if let unitId = unitId { dict["unitId"] = unitId }
            return try? encoder.encode(dict)
        case .sendChatMessage(_, let text, let quickReplyValue):
            var dict: [String: String] = ["text": text]
            if let value = quickReplyValue { dict["quickReplyValue"] = value }
            return try? encoder.encode(dict)
        case .registerPushToken(let fcmToken, let contactId):
            return try? encoder.encode([
                "fcmToken": fcmToken,
                "contactId": contactId,
                "platform": "ios"
            ])
        case .joinWaitlist(let waitlistBody):
            return try? encoder.encode(waitlistBody)
        default:
            return nil
        }
    }

    /// Builds a URLRequest from the endpoint definition.
    func urlRequest(baseURL: String) -> URLRequest {
        var components = URLComponents(string: baseURL + path)
        components?.queryItems = queryItems

        guard let url = components?.url else {
            fatalError("[PropHub] Invalid URL for endpoint: \(path)")
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = AppConfig.requestTimeoutSeconds

        if let body = body {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("PropHub-iOS/\(AppConfig.appVersion)", forHTTPHeaderField: "User-Agent")

        return request
    }
}

/// Request body for creating a service request.
struct ServiceRequestBody: Encodable {
    let category: String
    let subject: String
    let description: String
    let preferredDate: String?
    let assetId: String?
}

/// Request body for joining a waitlist.
struct WaitlistBody: Encodable {
    let contactId: String
    let launchId: String
    let preferredUnitType: String?
    let notes: String?
}
