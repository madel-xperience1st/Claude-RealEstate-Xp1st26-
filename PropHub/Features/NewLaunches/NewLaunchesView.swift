import SwiftUI
import Kingfisher

/// Browse new project launches with waitlist enrollment capability.
struct NewLaunchesView: View {
    @State private var launches: [ProjectLaunch] = []
    @State private var isLoading = false
    @State private var error: APIError?
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(launches) { launch in
                        NavigationLink(destination: LaunchDetailView(launch: launch)) {
                            LaunchCard(launch: launch)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle(NSLocalizedString("new_launches_title", comment: ""))
            .loading(isLoading)
            .emptyState(
                launches.isEmpty && !isLoading,
                icon: "sparkles",
                title: NSLocalizedString("no_launches_title", comment: ""),
                message: NSLocalizedString("no_launches_message", comment: "")
            )
            .task {
                await loadLaunches()
            }
        }
    }

    private func loadLaunches() async {
        isLoading = true
        do {
            launches = try await APIService.shared.request(
                .listLaunches(projectId: UserSession.shared.activeProjectId),
                cacheKey: "launches"
            )
        } catch let apiError as APIError {
            error = apiError
        } catch {
            self.error = .networkError(error.localizedDescription)
        }
        isLoading = false
    }
}

/// Card for a project launch in the list.
struct LaunchCard: View {
    let launch: ProjectLaunch
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Hero Image
            if let firstURL = launch.imageURLs.first {
                KFImage(firstURL)
                    .placeholder {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray5))
                            .frame(height: 180)
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(launch.name)
                    .font(.headline)

                if let handover = launch.expectedHandover {
                    Label(handover, systemImage: "calendar")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if let min = launch.priceRangeMin, let max = launch.priceRangeMax {
                    HStack {
                        CurrencyText(amount: min, currencyCode: themeManager.currencyCode, style: .caption)
                        Text("-")
                            .font(.caption)
                        CurrencyText(amount: max, currencyCode: themeManager.currencyCode, style: .caption)
                    }
                    .foregroundStyle(themeManager.primaryColor)
                }
            }
            .padding(.horizontal, 4)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(.background))
        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        .accessibilityElement(children: .combine)
    }
}

/// Detailed view of a project launch with waitlist enrollment.
struct LaunchDetailView: View {
    let launch: ProjectLaunch
    @State private var showWaitlistSheet = false
    @State private var joinedWaitlist = false
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Image Carousel
                TabView {
                    ForEach(launch.imageURLs, id: \.self) { url in
                        KFImage(url)
                            .resizable()
                            .scaledToFill()
                    }
                }
                .frame(height: 250)
                .tabViewStyle(.page)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)

                // Description
                if let description = launch.description {
                    Text(description)
                        .font(.body)
                        .padding(.horizontal)
                }

                // Details
                VStack(alignment: .leading, spacing: 8) {
                    if let handover = launch.expectedHandover {
                        detailRow(
                            icon: "calendar",
                            label: NSLocalizedString("expected_handover", comment: ""),
                            value: handover
                        )
                    }
                    if let min = launch.priceRangeMin, let max = launch.priceRangeMax {
                        HStack {
                            Image(systemName: "banknote")
                                .frame(width: 24)
                            Text(NSLocalizedString("price_range", comment: ""))
                                .foregroundStyle(.secondary)
                            Spacer()
                            HStack(spacing: 4) {
                                CurrencyText(amount: min, currencyCode: themeManager.currencyCode, style: .caption)
                                Text("-")
                                CurrencyText(amount: max, currencyCode: themeManager.currencyCode, style: .caption)
                            }
                        }
                        .font(.subheadline)
                    }
                }
                .padding(.horizontal)

                // Amenities
                if !launch.amenitiesList.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(NSLocalizedString("amenities_title", comment: ""))
                            .font(.headline)
                        FlowLayout(spacing: 8) {
                            ForEach(launch.amenitiesList, id: \.self) { amenity in
                                Text(amenity)
                                    .font(.caption)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(
                                        Capsule()
                                            .fill(themeManager.primaryColor.opacity(0.1))
                                    )
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                // Join Waitlist Button
                Button {
                    showWaitlistSheet = true
                } label: {
                    HStack {
                        Image(systemName: joinedWaitlist ? "checkmark.circle.fill" : "bell.fill")
                        Text(joinedWaitlist
                             ? NSLocalizedString("on_waitlist", comment: "")
                             : NSLocalizedString("join_waitlist", comment: ""))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                }
                .buttonStyle(.borderedProminent)
                .tint(joinedWaitlist ? .green : themeManager.primaryColor)
                .disabled(joinedWaitlist)
                .padding()
                .accessibilityLabel(NSLocalizedString("join_waitlist", comment: ""))
            }
        }
        .navigationTitle(launch.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func detailRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 24)
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .font(.subheadline)
    }
}
