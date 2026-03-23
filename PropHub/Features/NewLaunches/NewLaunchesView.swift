import SwiftUI
import Kingfisher

/// Premium new launches showcase.
struct NewLaunchesView: View {
    @State private var launches: [ProjectLaunch] = []
    @State private var isLoading = false
    @State private var error: APIError?
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        NavigationStack {
            ZStack {
                Color.brandWhite.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 20) {
                        ForEach(launches) { launch in
                            NavigationLink(destination: LaunchDetailView(launch: launch)) {
                                LaunchCard(launch: launch)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("New Launches")
            .loading(isLoading)
            .emptyState(
                launches.isEmpty && !isLoading,
                icon: "sparkles",
                title: "No Launches",
                message: "No upcoming projects at the moment."
            )
            .task { await loadLaunches() }
        }
    }

    private func loadLaunches() async {
        isLoading = true
        if AppSettings.shared.useMockData {
            try? await Task.sleep(nanoseconds: 300_000_000)
            launches = MockDataProvider.projectLaunches
            isLoading = false
            return
        }
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

/// Premium launch card.
struct LaunchCard: View {
    let launch: ProjectLaunch
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Hero Image
            if let firstURL = launch.imageURLs.first {
                KFImage(firstURL)
                    .placeholder {
                        RoundedRectangle(cornerRadius: 0)
                            .fill(Color.brandPlatinum)
                            .frame(height: 200)
                            .overlay {
                                Image(systemName: "photo")
                                    .font(.title)
                                    .foregroundStyle(.brandGray)
                            }
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipped()
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(launch.name)
                    .font(.headline)
                    .foregroundStyle(.brandCharcoal)

                if let handover = launch.expectedHandover {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.caption2)
                            .foregroundStyle(.brandGold)
                        Text(handover)
                            .font(.caption)
                            .foregroundStyle(.brandGray)
                    }
                }

                if let min = launch.priceRangeMin, let max = launch.priceRangeMax {
                    HStack(spacing: 4) {
                        CurrencyText(amount: min, currencyCode: themeManager.currencyCode, style: .caption)
                        Text("-")
                            .font(.caption)
                        CurrencyText(amount: max, currencyCode: themeManager.currencyCode, style: .caption)
                    }
                    .foregroundStyle(.brandGold)
                }
            }
            .padding(16)
        }
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.white)
                .shadow(color: .black.opacity(0.06), radius: 10, y: 5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

/// Premium launch detail with waitlist.
struct LaunchDetailView: View {
    let launch: ProjectLaunch
    @State private var showWaitlistSheet = false
    @State private var joinedWaitlist = false
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        ZStack {
            Color.brandWhite.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    // Image Carousel
                    TabView {
                        ForEach(launch.imageURLs, id: \.self) { url in
                            KFImage(url)
                                .resizable()
                                .scaledToFill()
                        }
                    }
                    .frame(height: 260)
                    .tabViewStyle(.page)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .padding(.horizontal, 20)

                    if let description = launch.description {
                        Text(description)
                            .font(.body)
                            .foregroundStyle(.brandCharcoal)
                            .padding(.horizontal, 20)
                    }

                    // Details
                    VStack(spacing: 12) {
                        if let handover = launch.expectedHandover {
                            detailRow(icon: "calendar", label: "Expected Handover", value: handover)
                        }
                        if let min = launch.priceRangeMin, let max = launch.priceRangeMax {
                            HStack {
                                Image(systemName: "banknote")
                                    .foregroundStyle(.brandGold)
                                    .frame(width: 24)
                                Text("Price Range")
                                    .foregroundStyle(.brandGray)
                                Spacer()
                                HStack(spacing: 4) {
                                    CurrencyText(amount: min, currencyCode: themeManager.currencyCode, style: .caption)
                                    Text("-")
                                    CurrencyText(amount: max, currencyCode: themeManager.currencyCode, style: .caption)
                                }
                                .foregroundStyle(.brandCharcoal)
                            }
                            .font(.subheadline)
                        }
                    }
                    .padding(18)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.white)
                            .shadow(color: .black.opacity(0.04), radius: 8, y: 4)
                    )
                    .padding(.horizontal, 20)

                    // Amenities
                    if !launch.amenitiesList.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            SectionHeader(title: "Amenities", icon: "sparkles")
                            FlowLayout(spacing: 8) {
                                ForEach(launch.amenitiesList, id: \.self) { amenity in
                                    Text(amenity)
                                        .font(.caption)
                                        .foregroundStyle(.brandNavy)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 7)
                                        .background(
                                            Capsule().fill(Color.brandChampagne)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    // Waitlist Button
                    Button {
                        showWaitlistSheet = true
                        joinedWaitlist = true
                    } label: {
                        HStack {
                            Image(systemName: joinedWaitlist ? "checkmark.circle.fill" : "bell.fill")
                            Text(joinedWaitlist ? "On Waitlist" : "Join Waitlist")
                                .font(.headline)
                        }
                        .foregroundStyle(joinedWaitlist ? .brandEmerald : .brandNavy)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(
                            joinedWaitlist
                            ? AnyShapeStyle(Color.brandEmerald.opacity(0.12))
                            : AnyShapeStyle(Color.goldGradient)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(joinedWaitlist)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                .padding(.vertical)
            }
        }
        .navigationTitle(launch.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func detailRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.brandGold)
                .frame(width: 24)
            Text(label)
                .foregroundStyle(.brandGray)
            Spacer()
            Text(value)
                .fontWeight(.medium)
                .foregroundStyle(.brandCharcoal)
        }
        .font(.subheadline)
    }
}
