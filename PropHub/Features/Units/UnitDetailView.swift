import SwiftUI
import Kingfisher

/// Detailed view of a single unit showing floor plan, payment progress, and quick actions.
struct UnitDetailView: View {
    let unit: Unit
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Floor Plan Image
                if let floorPlanUrl = unit.floorPlanUrl, let url = URL(string: floorPlanUrl) {
                    KFImage(url)
                        .placeholder {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray5))
                                .overlay {
                                    Image(systemName: "photo")
                                        .font(.largeTitle)
                                        .foregroundStyle(.secondary)
                                }
                        }
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                        .accessibilityLabel(NSLocalizedString("floor_plan", comment: ""))
                }

                // Unit Info Card
                VStack(spacing: 12) {
                    infoRow(
                        label: NSLocalizedString("unit_number_label", comment: ""),
                        value: unit.unitNumber
                    )
                    infoRow(
                        label: NSLocalizedString("building_label", comment: ""),
                        value: unit.building
                    )
                    infoRow(
                        label: NSLocalizedString("floor_label", comment: ""),
                        value: "\(unit.floor)"
                    )
                    infoRow(
                        label: NSLocalizedString("type_label", comment: ""),
                        value: unit.unitType
                    )
                    infoRow(
                        label: NSLocalizedString("area_label", comment: ""),
                        value: "\(Int(unit.areaSqm)) sqm / \(Int(unit.areaSqft)) sqft"
                    )
                    infoRow(
                        label: NSLocalizedString("status_label", comment: ""),
                        value: unit.status
                    )
                    if let handoverDate = unit.handoverDate {
                        infoRow(
                            label: NSLocalizedString("handover_label", comment: ""),
                            value: handoverDate.mediumFormatted
                        )
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(.background))
                .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                .padding(.horizontal)

                // Payment Progress
                if let completion = unit.paymentCompletion {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(NSLocalizedString("payment_progress", comment: ""))
                            .font(.headline)
                        ProgressView(value: completion)
                            .scaleEffect(y: 2)
                            .tint(themeManager.primaryColor)
                        HStack {
                            CurrencyText(
                                amount: unit.totalPrice * completion,
                                currencyCode: themeManager.currencyCode,
                                style: .caption
                            )
                            .foregroundStyle(.green)
                            Spacer()
                            CurrencyText(
                                amount: unit.totalPrice,
                                currencyCode: themeManager.currencyCode,
                                style: .caption
                            )
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(.background))
                    .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                    .padding(.horizontal)
                }

                // Quick Actions
                VStack(spacing: 12) {
                    NavigationLink(destination: InstallmentView(unitId: unit.id)) {
                        quickActionRow(
                            icon: "creditcard",
                            title: NSLocalizedString("view_payments", comment: ""),
                            color: .blue
                        )
                    }
                    NavigationLink(destination: ServiceRequestView()) {
                        quickActionRow(
                            icon: "wrench.and.screwdriver",
                            title: NSLocalizedString("request_service", comment: ""),
                            color: .orange
                        )
                    }
                    NavigationLink(destination: AssetListView(unitId: unit.id)) {
                        quickActionRow(
                            icon: "shippingbox",
                            title: NSLocalizedString("view_assets", comment: ""),
                            color: .purple
                        )
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle(unit.unitNumber)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .accessibilityElement(children: .combine)
    }

    private func quickActionRow(icon: String, title: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 32)
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(.background))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        .accessibilityLabel(title)
    }
}
