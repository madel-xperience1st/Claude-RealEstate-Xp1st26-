import SwiftUI

/// Visual warranty timeline showing warranty periods with color coding.
struct WarrantyView: View {
    let asset: Asset
    let warranty: Warranty?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let warranty = warranty {
                    // Warranty Timeline
                    VStack(alignment: .leading, spacing: 8) {
                        Text(NSLocalizedString("warranty_period", comment: ""))
                            .font(.headline)

                        HStack {
                            VStack(alignment: .leading) {
                                Text(NSLocalizedString("start_date", comment: ""))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(warranty.startDate.mediumFormatted)
                                    .font(.subheadline)
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text(NSLocalizedString("end_date", comment: ""))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(warranty.endDate.mediumFormatted)
                                    .font(.subheadline)
                            }
                        }

                        // Visual timeline bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(.systemGray5))
                                    .frame(height: 8)
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(timelineColor)
                                    .frame(
                                        width: geometry.size.width * progressValue,
                                        height: 8
                                    )
                            }
                        }
                        .frame(height: 8)

                        Text(warranty.status)
                            .font(.caption)
                            .foregroundStyle(timelineColor)
                            .fontWeight(.medium)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(.background))
                    .shadow(color: .black.opacity(0.05), radius: 4, y: 2)

                    // Provider
                    if let provider = warranty.provider {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(NSLocalizedString("provider_label", comment: ""))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(provider)
                                .font(.subheadline)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 12).fill(.background))
                        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                    }

                    // Terms
                    if let terms = warranty.terms {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(NSLocalizedString("warranty_terms", comment: ""))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(terms)
                                .font(.subheadline)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 12).fill(.background))
                        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                    }
                } else {
                    EmptyStateView(
                        icon: "shield.slash",
                        title: NSLocalizedString("no_warranty_title", comment: ""),
                        message: NSLocalizedString("no_warranty_message", comment: "")
                    )
                }
            }
            .padding()
        }
    }

    private var timelineColor: Color {
        switch asset.warrantyStatus.lowercased() {
        case "active": return .green
        case "expiring soon": return .orange
        case "expired": return .red
        default: return .gray
        }
    }

    private var progressValue: Double {
        guard let warranty = warranty else { return 0 }
        let total = warranty.endDate.timeIntervalSince(warranty.startDate)
        let elapsed = Date().timeIntervalSince(warranty.startDate)
        return min(max(elapsed / total, 0), 1)
    }
}
