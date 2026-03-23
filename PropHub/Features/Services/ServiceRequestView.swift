import SwiftUI

/// Premium service requests list — standalone with its own NavigationStack.
struct ServiceRequestView: View {
    @StateObject private var viewModel = ServiceViewModel()
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showCreateForm = false
    @State private var selectedUnitId: String?

    var body: some View {
        NavigationStack {
            ServiceRequestListContent(viewModel: viewModel, showCreateForm: $showCreateForm, selectedUnitId: $selectedUnitId)
                .task {
                    let unitId = MockDataProvider.units.first?.id ?? UserSession.shared.activeProjectId ?? "unit-001"
                    selectedUnitId = unitId
                    await viewModel.loadServiceRequests(unitId: unitId)
                }
        }
    }
}

/// Embeddable service request list content — used inside parent NavigationStack (Units tab).
struct ServiceRequestListContent: View {
    @StateObject private var ownViewModel = ServiceViewModel()
    @EnvironmentObject var themeManager: ThemeManager
    @State private var ownShowCreateForm = false
    @State private var ownSelectedUnitId: String?

    // When used embedded, these are passed; when standalone, uses own state
    var viewModel: ServiceViewModel?
    var showCreateForm: Binding<Bool>?
    var selectedUnitId: Binding<String?>?

    private var vm: ServiceViewModel { viewModel ?? ownViewModel }
    private var createFormBinding: Binding<Bool> { showCreateForm ?? $ownShowCreateForm }
    private var unitIdBinding: Binding<String?> { selectedUnitId ?? $ownSelectedUnitId }

    init() {
        self.viewModel = nil
        self.showCreateForm = nil
        self.selectedUnitId = nil
    }

    init(viewModel: ServiceViewModel, showCreateForm: Binding<Bool>, selectedUnitId: Binding<String?>) {
        self.viewModel = viewModel
        self.showCreateForm = showCreateForm
        self.selectedUnitId = selectedUnitId
    }

    var body: some View {
        ZStack {
            Color.brandWhite.ignoresSafeArea()

            List {
                ForEach(vm.serviceRequests) { request in
                    NavigationLink(value: AppRouter.Destination.serviceRequestDetail(requestId: request.id)) {
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
                Button { createFormBinding.wrappedValue = true } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(.brandNavy)
                }
            }
        }
        .sheet(isPresented: createFormBinding) {
            if let unitId = unitIdBinding.wrappedValue {
                ServiceRequestForm(unitId: unitId, viewModel: vm)
            }
        }
        .loading(vm.isLoading)
        .emptyState(
            vm.serviceRequests.isEmpty && !vm.isLoading,
            icon: "wrench.and.screwdriver",
            title: "No Requests",
            message: "No service requests yet."
        )
        .errorAlert(error: Binding(get: { vm.error }, set: { vm.error = $0 })) {
            if let unitId = unitIdBinding.wrappedValue {
                Task { await vm.loadServiceRequests(unitId: unitId) }
            }
        }
        .task {
            if viewModel == nil {
                let unitId = MockDataProvider.units.first?.id ?? UserSession.shared.activeProjectId ?? "unit-001"
                ownSelectedUnitId = unitId
                await ownViewModel.loadServiceRequests(unitId: unitId)
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

/// Full service request detail view.
struct ServiceRequestDetailView: View {
    let requestId: String
    @State private var request: ServiceRequest?
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        ZStack {
            Color.brandWhite.ignoresSafeArea()

            if let request = request {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Header Card
                        VStack(spacing: 14) {
                            HStack {
                                Text(request.caseNumber)
                                    .font(.headline)
                                    .foregroundStyle(.brandGold)
                                Spacer()
                                StatusBadge.forServiceStatus(request.status)
                            }

                            Divider()

                            infoRow(label: "Category", value: request.category, icon: "tag")
                            Divider()
                            infoRow(label: "Created", value: request.createdDate.mediumFormatted, icon: "calendar")

                            if let technician = request.assignedTechnician {
                                Divider()
                                infoRow(label: "Technician", value: technician, icon: "person.fill")
                            }

                            if let preferredDate = request.preferredDate {
                                Divider()
                                infoRow(label: "Preferred Date", value: preferredDate.mediumFormatted, icon: "clock")
                            }
                        }
                        .padding(18)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(.white)
                                .shadow(color: .black.opacity(0.04), radius: 8, y: 4)
                        )

                        // Description Card
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "Description", icon: "doc.text")

                            Text(request.description)
                                .font(.body)
                                .foregroundStyle(.brandCharcoal)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(18)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(.white)
                                .shadow(color: .black.opacity(0.04), radius: 8, y: 4)
                        )

                        // Related Asset
                        if request.relatedAssetId != nil {
                            if let asset = MockDataProvider.assets.first(where: { $0.id == request.relatedAssetId }) {
                                VStack(alignment: .leading, spacing: 12) {
                                    SectionHeader(title: "Related Asset", icon: "shippingbox")

                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(asset.name)
                                                .font(.subheadline.weight(.medium))
                                                .foregroundStyle(.brandCharcoal)
                                            Text(asset.serialNumber)
                                                .font(.caption)
                                                .foregroundStyle(.brandGray)
                                        }
                                        Spacer()
                                        StatusBadge(text: asset.warrantyStatus, color: warrantyColor(asset.warrantyStatus))
                                    }
                                }
                                .padding(18)
                                .background(
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(.white)
                                        .shadow(color: .black.opacity(0.04), radius: 8, y: 4)
                                )
                            }
                        }

                        // Contact Support
                        Button {
                            // Placeholder for contact support action
                        } label: {
                            HStack {
                                Image(systemName: "phone.fill")
                                Text("Contact Support")
                                    .font(.headline)
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color.brandNavy)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .padding(.bottom, 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical)
                }
            } else {
                ProgressView()
                    .tint(.brandGold)
            }
        }
        .navigationTitle("Request Detail")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            // Look up from mock data or API
            if AppSettings.shared.useMockData {
                try? await Task.sleep(nanoseconds: 200_000_000)
                request = MockDataProvider.serviceRequests.first { $0.id == requestId }
            }
        }
    }

    private func infoRow(label: String, value: String, icon: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.brandGold)
                .frame(width: 20)
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.brandGray)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.brandCharcoal)
        }
    }

    private func warrantyColor(_ status: String) -> Color {
        switch status.lowercased() {
        case "active": return .brandEmerald
        case "expiring soon": return .brandGold
        case "expired": return .brandCoral
        default: return .brandGray
        }
    }
}
