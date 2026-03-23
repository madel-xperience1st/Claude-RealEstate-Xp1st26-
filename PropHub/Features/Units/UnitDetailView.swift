import SwiftUI
import Kingfisher

/// Premium unit detail view with hero image and elegant layout.
struct UnitDetailView: View {
    let unit: Unit
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        ZStack {
            Color.brandWhite.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Hero image or floor plan
                    if let floorPlanUrl = unit.floorPlanUrl, let url = URL(string: floorPlanUrl) {
                        KFImage(url)
                            .placeholder {
                                ProjectHeroImage(
                                    primaryColor: themeManager.primaryColor,
                                    secondaryColor: themeManager.secondaryColor,
                                    icon: "photo",
                                    title: "FLOOR PLAN",
                                    height: 220
                                )
                            }
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .padding(.horizontal, 20)
                    } else {
                        UnitHeroCard(unit: unit)
                            .padding(.horizontal, 20)
                    }

                    // Unit Info Card
                    VStack(spacing: 0) {
                        infoRow(label: "Unit", value: unit.unitNumber)
                            .padding(.vertical, 14)
                        Divider()
                        infoRow(label: "Building", value: unit.building)
                            .padding(.vertical, 14)
                        Divider()
                        infoRow(label: "Floor", value: "\(unit.floor)")
                            .padding(.vertical, 14)
                        Divider()
                        infoRow(label: "Type", value: unit.unitType)
                            .padding(.vertical, 14)
                        Divider()
                        infoRow(label: "Area", value: "\(Int(unit.areaSqm)) sqm / \(Int(unit.areaSqft)) sqft")
                            .padding(.vertical, 14)
                        Divider()
                        HStack {
                            Text("Status")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundStyle(.brandGray)
                            Spacer()
                            StatusBadge.forUnitStatus(unit.status)
                        }
                        .padding(.vertical, 14)
                        if let handoverDate = unit.handoverDate {
                            Divider()
                            infoRow(label: "Handover", value: handoverDate.mediumFormatted)
                                .padding(.vertical, 14)
                        }
                    }
                    .padding(.horizontal, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.06), radius: 12, y: 6)
                    )
                    .padding(.horizontal, 20)

                    // Payment Progress
                    if let completion = unit.paymentCompletion {
                        VStack(alignment: .leading, spacing: 14) {
                            SectionHeader(title: "Payment Progress", icon: "creditcard.fill")

                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(Color.brandPlatinum)
                                        .frame(height: 8)
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(
                                            LinearGradient(
                                                colors: [themeManager.primaryColor, themeManager.secondaryColor],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: geo.size.width * completion, height: 8)
                                }
                            }
                            .frame(height: 8)

                            HStack {
                                CurrencyText(
                                    amount: unit.totalPrice * completion,
                                    currencyCode: themeManager.currencyCode,
                                    style: .caption
                                )
                                .foregroundStyle(.brandEmerald)
                                Spacer()
                                Text("\(Int(completion * 100))%")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundStyle(themeManager.secondaryColor)
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
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.06), radius: 12, y: 6)
                        )
                        .padding(.horizontal, 20)
                    }

                    // Quick Actions
                    VStack(spacing: 10) {
                        NavigationLink(value: AppRouter.Destination.installments(unitId: unit.id)) {
                            quickActionRow(icon: "creditcard", title: "View Payments", color: themeManager.primaryColor)
                        }
                        NavigationLink(value: AppRouter.Destination.serviceRequests) {
                            quickActionRow(icon: "wrench.and.screwdriver", title: "Request Service", color: themeManager.secondaryColor)
                        }
                        NavigationLink(value: AppRouter.Destination.assetList(unitId: unit.id)) {
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
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(.brandGray)
            Spacer()
            Text(value)
                .font(.system(size: 15, weight: .medium))
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
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(color)
            }
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.brandCharcoal)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.brandGray)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 12, y: 6)
        )
    }
}
