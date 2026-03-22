import Foundation

/// Central HTTP client for all MuleSoft API communication.
/// Handles token injection, automatic retry on 401, rate limiting, and caching.
@MainActor
final class APIService {
    static let shared = APIService()

    private let session: URLSession
    private let tokenManager: TokenManager
    private let cacheManager: CacheManager
    private let networkMonitor: NetworkMonitor
    private var baseURL: String {
        Environment.shared.muleBaseURL
    }

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = AppConfig.requestTimeoutSeconds
        config.timeoutIntervalForResource = 60
        config.waitsForConnectivity = true
        self.session = URLSession(configuration: config)
        self.tokenManager = TokenManager.shared
        self.cacheManager = CacheManager.shared
        self.networkMonitor = NetworkMonitor.shared
    }

    /// Performs an authenticated API request and decodes the response.
    /// Automatically retries once on 401 (token expired) after refreshing the token.
    /// Falls back to cached data when offline.
    func request<T: Decodable>(
        _ endpoint: APIRouter,
        cacheKey: String? = nil
    ) async throws -> T {
        // Check for cached data when offline
        if !networkMonitor.isConnected, let key = cacheKey,
           let cached: T = cacheManager.retrieve(forKey: key, as: T.self) {
            return cached
        }

        guard networkMonitor.isConnected else {
            throw APIError.offlineNoCache
        }

        var urlRequest = endpoint.urlRequest(baseURL: baseURL)

        // Inject auth token for non-auth endpoints
        if case .authToken = endpoint {
            // No token needed for initial auth
        } else {
            let token = try await tokenManager.validToken()
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await performRequest(urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            let decoded: T = try decode(data)
            if let key = cacheKey, let encodable = decoded as? any Encodable {
                cacheManager.storeEncodable(encodable, forKey: key)
            }
            return decoded

        case 401:
            // Token expired — refresh and retry once
            try await tokenManager.refreshToken()
            return try await retryRequest(endpoint)

        case 403:
            throw APIError.forbidden

        case 404:
            throw APIError.notFound

        case 429:
            throw APIError.rateLimited

        default:
            throw APIError.serverError(httpResponse.statusCode)
        }
    }

    /// Performs a request that returns raw Data (e.g., PDF downloads).
    func requestData(_ endpoint: APIRouter) async throws -> Data {
        var urlRequest = endpoint.urlRequest(baseURL: baseURL)
        let token = try await tokenManager.validToken()
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await performRequest(urlRequest)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }

        return data
    }

    /// Uploads multipart form data (e.g., photo attachments).
    func uploadMultipart(
        _ endpoint: APIRouter,
        imageData: Data,
        fileName: String,
        mimeType: String = "image/jpeg"
    ) async throws -> AttachmentResponse {
        var urlRequest = endpoint.urlRequest(baseURL: baseURL)
        let token = try await tokenManager.validToken()
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let boundary = UUID().uuidString
        urlRequest.setValue(
            "multipart/form-data; boundary=\(boundary)",
            forHTTPHeaderField: "Content-Type"
        )

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8) ?? Data())
        body.append(
            "Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n"
                .data(using: .utf8) ?? Data()
        )
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8) ?? Data())
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8) ?? Data())

        urlRequest.httpBody = body

        let (data, response) = try await performRequest(urlRequest)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }

        return try decode(data)
    }

    // MARK: - Private

    private func performRequest(_ request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await session.data(for: request)
        } catch {
            throw APIError.networkError(error.localizedDescription)
        }
    }

    private func retryRequest<T: Decodable>(_ endpoint: APIRouter) async throws -> T {
        var urlRequest = endpoint.urlRequest(baseURL: baseURL)
        let token = try await tokenManager.validToken()
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await performRequest(urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            if httpResponse.statusCode == 401 {
                throw APIError.tokenExpired
            }
            throw APIError.serverError(httpResponse.statusCode)
        }

        return try decode(data)
    }

    private func decode<T: Decodable>(_ data: Data) throws -> T {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error.localizedDescription)
        }
    }
}

/// Response model for attachment uploads.
struct AttachmentResponse: Decodable {
    let attachmentId: String
}
