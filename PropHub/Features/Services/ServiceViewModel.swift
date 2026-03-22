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

    /// Fetches service requests for the first unit of the active project.
    func loadServiceRequests(unitId: String) async {
        isLoading = true
        error = nil

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

            // Upload photo if provided
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

            // Refresh list
            await loadServiceRequests(unitId: unitId)
        } catch let apiError as APIError {
            error = apiError
        } catch {
            self.error = .networkError(error.localizedDescription)
        }

        isSubmitting = false
    }
}
