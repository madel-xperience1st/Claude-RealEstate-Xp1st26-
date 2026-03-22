import Foundation
import UIKit

/// View model managing service request listing and creation.
@MainActor
final class ServiceViewModel: ObservableObject {
    @Published var serviceRequests: [ServiceRequest] = []
    @Published var isLoading = false
    @Published var isSubmitting = false
    @Published var error: APIError?
    @Published var successMessage: String?

    private let apiService = APIService.shared
    private let userSession = UserSession.shared
    private let settings = AppSettings.shared

    /// Fetches service requests for a unit.
    func loadServiceRequests(unitId: String) async {
        isLoading = true
        error = nil

        if settings.useMockData {
            try? await Task.sleep(nanoseconds: 300_000_000)
            serviceRequests = MockDataProvider.serviceRequests
            isLoading = false
            return
        }

        do {
            serviceRequests = try await apiService.request(
                .listServiceRequests(unitId: unitId, status: nil),
                cacheKey: "services.\(unitId)"
            )
        } catch let apiError as APIError {
            error = apiError
        } catch {
            self.error = .networkError(error.localizedDescription)
        }

        isLoading = false
    }

    /// Creates a new service request and optionally uploads a photo attachment.
    func createServiceRequest(
        unitId: String,
        category: String,
        subject: String,
        description: String,
        preferredDate: Date?,
        assetId: String?,
        photo: UIImage?
    ) async {
        isSubmitting = true
        error = nil
        successMessage = nil

        if settings.useMockData {
            try? await Task.sleep(nanoseconds: 600_000_000)
            let newRequest = ServiceRequest(
                id: "sr-new-\(UUID().uuidString.prefix(4))",
                caseNumber: "CS-\(String(format: "%06d", Int.random(in: 3000...9999)))",
                category: category,
                subject: subject,
                status: "New",
                createdDate: Date(),
                assignedTechnician: nil,
                description: description,
                preferredDate: preferredDate,
                relatedAssetId: assetId
            )
            serviceRequests.insert(newRequest, at: 0)
            successMessage = String(
                format: NSLocalizedString("service_created", comment: ""),
                newRequest.caseNumber
            )
            isSubmitting = false
            return
        }

        let dateFormatter = ISO8601DateFormatter()
        let body = ServiceRequestBody(
            category: category,
            subject: subject,
            description: description,
            preferredDate: preferredDate.map { dateFormatter.string(from: $0) },
            assetId: assetId
        )

        do {
            let response: ServiceRequest = try await apiService.request(
                .createServiceRequest(unitId: unitId, body: body)
            )

            if let photo = photo, let imageData = photo.jpegData(compressionQuality: 0.8) {
                _ = try await apiService.uploadMultipart(
                    .uploadAttachment(requestId: response.id),
                    imageData: imageData,
                    fileName: "service_photo.jpg"
                )
            }

            successMessage = String(
                format: NSLocalizedString("service_created", comment: ""),
                response.caseNumber
            )

            await loadServiceRequests(unitId: unitId)
        } catch let apiError as APIError {
            error = apiError
        } catch {
            self.error = .networkError(error.localizedDescription)
        }

        isSubmitting = false
    }
}
