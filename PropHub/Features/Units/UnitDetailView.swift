import SwiftUI
import Kingfisher

/// Premium unit detail view with elegant layout.
struct UnitDetailView: View {
    let unit: Unit
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        ZStack {
            Color.brandWhite.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Floor Plan
                    if let floorPlanUrl = unit.floorPlanUrl, let url = URL(string: floorPlanUrl) {
                        KFImage(url)
                            .placeholder {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.brandPlatinum)
                                    .frame(height: 220)
                                    .overlay {
                                        VStack(spacing: 8) {
                                            Image(systemName: "photo")
                                                .font(.largeTitle)
                                                .foregroundStyle(.brandGray)
                                            Text("Floor Plan")
                                                .font(.caption)
                                                .foregroundStyle(.brandGray)
                                        }
                                    }
                            }
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .padding(.horizontal, 20)
                    }

                    // Unit Info Card
                    VStack(spacing: 14) {
                        infoRow(label: "Unit", value: unit.unitNumber)
                        Divider()
                        infoRow(label: "Building", value: unit.building)
                        Divider()
                        infoRow(label: "Floor", value: "\(unit.floor)")
                        Divider()
                        infoRow(label: "Type", value: unit.unitType)
                        Divider()
                        infoRow(label: "Area", value: "\(Int(unit.areaSqm)) sqm / \(Int(unit.areaSqft)) sqft")
                        Divider()
                        HStack {
                            Text("Status")
                                .font(.subheadline)
                                .foregroundStyle(.brandGray)
                            Spacer()
                            StatusBadge.forUnitStatus(unit.status)
                        }
                        if let handoverDate = unit.handoverDate {
                            Divider()
                            infoRow(label: "Handover", value: handoverDate.mediumFormatted)
                        }
                    }
                    .padding(18)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(.white)
                            .shadow(color: .black.opacity(0.04), radius: 8, y: 4)
                    )
                    .padding(.horizontal, 20)

                    // Payment Progress
                    if let completion = unit.paymentCompletion {
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "Payment Progress", icon: "creditcard.fill")

                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.brandPlatinum)
                                        .frame(height: 10)
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.goldGradient)
                                        .frame(width: geo.size.width * completion, height: 10)
                                }
                            }
                            .frame(height: 10)

                            HStack {
                                CurrencyText(
                                    amount: unit.totalPrice * completion,
                                    currencyCode: themeManager.currencyCode,
                                    style: .caption
                                )
                                .foregroundStyle(.brandEmerald)
                                Spacer()
                                Text("\(Int(completion * 100))%")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(.brandGold)
                                Spacer()
                                CurrencyText(
                                    amount: unit.totalPrice,
                                    currencyCode: themeManager.currencyCode,
                                    style: .caption
                                )
                                .foregroundStyle(.brandCharcoal)
                            }
                        }
                        .padding(18)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(.white)
                                .shadow(color: .black.opacity(0.04), radius: 8, y: 4)
                        )
                        .padding(.horizontal, 20)
                    }

                    // Quick Actions
                    VStack(spacing: 12) {
                        NavigationLink(destination: InstallmentView(unitId: unit.id)) {
                            quickActionRow(icon: "creditcard", title: "View Payments", color: .brandNavy)
                        }
                        NavigationLink(destination: ServiceRequestView()) {
                            quickActionRow(icon: "wrench.and.screwdriver", title: "Request Service", color: .brandGold)
                        }
                        NavigationLink(destination: AssetListView(unitId: unit.id)) {
                            quickActionRow(icon: "shippingbox", title: "View Assets", color: .brandSky)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                .padding(.vertical)
            }
        }
        .navigationTitle(unit.unitNumber)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.brandGray)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.brandCharcoal)
        }
    }

    private func quickActionRow(icon: String, title: String, color: Color) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(0.1))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.body)
                    .foregroundStyle(color)
            }
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.brandCharcoal)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.brandGray)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
                .shadow(color: .black.opacity(0.04), radius: 8, y: 4)
        )
    }
}
