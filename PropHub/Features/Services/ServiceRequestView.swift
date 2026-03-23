import SwiftUI

/// Premium service requests list.
struct ServiceRequestView: View {
    @StateObject private var viewModel = ServiceViewModel()
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showCreateForm = false
    @State private var selectedUnitId: String?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.brandWhite.ignoresSafeArea()

                List {
                    ForEach(viewModel.serviceRequests) { request in
                        NavigationLink(destination: ServiceRequestDetailView(requestId: request.id)) {
                            ServiceRequestListRow(request: request)
                        }
                        .listRowBackground(Color.brandWhite)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Services")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showCreateForm = true } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.brandNavy)
                    }
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
                title: "No Requests",
                message: "No service requests yet."
            )
            .errorAlert(error: $viewModel.error) {
                if let unitId = selectedUnitId {
                    Task { await viewModel.loadServiceRequests(unitId: unitId) }
                }
            }
            .task {
                let unitId = MockDataProvider.units.first?.id ?? UserSession.shared.activeProjectId ?? "unit-001"
                selectedUnitId = unitId
                await viewModel.loadServiceRequests(unitId: unitId)
            }
        }
    }
}

/// Premium service request row.
struct ServiceRequestListRow: View {
    let request: ServiceRequest

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(request.caseNumber)
                    .font(.caption)
                    .foregroundStyle(.brandGold)
                Spacer()
                StatusBadge.forServiceStatus(request.status)
            }

            Text(request.subject)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.brandCharcoal)
                .lineLimit(2)

            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "tag")
                        .font(.caption2)
                        .foregroundStyle(.brandGold)
                    Text(request.category)
                        .font(.caption)
                        .foregroundStyle(.brandGray)
                }
                Spacer()
                Text(request.createdDate.relativeFormatted)
                    .font(.caption)
                    .foregroundStyle(.brandGray)
            }

            if let technician = request.assignedTechnician {
                HStack(spacing: 4) {
                    Image(systemName: "person.fill")
                        .font(.caption2)
                        .foregroundStyle(.brandSky)
                    Text(technician)
                        .font(.caption)
                        .foregroundStyle(.brandSky)
                }
            }
        }
        .padding(.vertical, 6)
    }
}

/// Placeholder detail view for a service request.
struct ServiceRequestDetailView: View {
    let requestId: String

    var body: some View {
        ZStack {
            Color.brandWhite.ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: "wrench.and.screwdriver")
                    .font(.system(size: 40))
                    .foregroundStyle(.brandGold)
                Text("Request Details")
                    .font(.headline)
                    .foregroundStyle(.brandCharcoal)
                Text("Detailed view coming soon")
                    .font(.subheadline)
                    .foregroundStyle(.brandGray)
            }
        }
        .navigationTitle("Request Detail")
    }
}
