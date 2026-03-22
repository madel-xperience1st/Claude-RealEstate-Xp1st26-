import SwiftUI

/// List of service requests with ability to create new ones.
struct ServiceRequestView: View {
    @StateObject private var viewModel = ServiceViewModel()
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showCreateForm = false
    @State private var selectedUnitId: String?

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.serviceRequests) { request in
                    NavigationLink(destination: ServiceRequestDetailView(requestId: request.id)) {
                        ServiceRequestListRow(request: request)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle(NSLocalizedString("tab_services", comment: ""))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showCreateForm = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityLabel(NSLocalizedString("new_request", comment: ""))
                }
            }
            .sheet(isPresented: $showCreateForm) {
                if let unitId = selectedUnitId {
                    ServiceRequestForm(unitId: unitId, viewModel: viewModel)
                }
            }
            .loading(viewModel.isLoading)
            .emptyState(
                viewModel.serviceRequests.isEmpty && !viewModel.isLoading,
                icon: "wrench.and.screwdriver",
                title: NSLocalizedString("no_requests_title", comment: ""),
                message: NSLocalizedString("no_requests_message", comment: "")
            )
            .errorAlert(error: $viewModel.error) {
                if let unitId = selectedUnitId {
                    Task { await viewModel.loadServiceRequests(unitId: unitId) }
                }
            }
            .task {
                let unitId = UserSession.shared.activeProjectId ?? ""
                selectedUnitId = unitId
                await viewModel.loadServiceRequests(unitId: unitId)
            }
        }
    }
}

/// Row for a service request in the list.
struct ServiceRequestListRow: View {
    let request: ServiceRequest

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(request.caseNumber)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                StatusBadge.forServiceStatus(request.status)
            }

            Text(request.subject)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(2)

            HStack {
                Label(request.category, systemImage: "tag")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(request.createdDate.relativeFormatted)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            if let technician = request.assignedTechnician {
                Label(technician, systemImage: "person.fill")
                    .font(.caption)
                    .foregroundStyle(.blue)
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }
}

/// Placeholder detail view for a service request.
struct ServiceRequestDetailView: View {
    let requestId: String

    var body: some View {
        Text(NSLocalizedString("service_detail_placeholder", comment: ""))
            .navigationTitle(NSLocalizedString("request_detail", comment: ""))
    }
}
