import SwiftUI
import Kingfisher

/// Premium new launches showcase.
struct NewLaunchesView: View {
    @State private var launches: [ProjectLaunch] = []
    @State private var isLoading = false
    @State private var error: APIError?
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var router: AppRouter

    var body: some View {
        NavigationStack(path: $router.launchesPath) {
            ZStack {
                Color.brandWhite.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 20) {
                        ForEach(launches) { launch in
                            NavigationLink(value: AppRouter.Destination.launchDetail(launch)) {
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
            .navigationDestination(for: AppRouter.Destination.self) { destination in
                destinationView(for: destination)
            }
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

/// Premium launch card with hero image area.
struct LaunchCard: View {
    let launch: ProjectLaunch
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Hero Image or gradient placeholder
            if let firstURL = launch.imageURLs.first {
                KFImage(firstURL)
                    .placeholder {
                        ProjectHeroImage(
                            primaryColor: themeManager.primaryColor,
                            secondaryColor: themeManager.secondaryColor,
                            icon: "sparkles",
                            title: "NEW LAUNCH",
                            height: 200
                        )
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipped()
            } else {
                ProjectHeroImage(
                    primaryColor: themeManager.primaryColor,
                    secondaryColor: themeManager.secondaryColor,
                    icon: "sparkles",
                    title: "NEW LAUNCH",
                    height: 200
                )
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(launch.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.brandCharcoal)

                if let handover = launch.expectedHandover {
                    HStack(spacing: 5) {
                        Image(systemName: "calendar")
                            .font(.system(size: 10))
                            .foregroundStyle(themeManager.secondaryColor)
                        Text(handover)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.brandGray)
                    }
                }

                if let min = launch.priceRangeMin, let max = launch.priceRangeMax {
                    HStack(spacing: 4) {
                        CurrencyText(amount: min, currencyCode: themeManager.currencyCode, style: .caption)
                        Text("–")
                            .font(.system(size: 12))
                        CurrencyText(amount: max, currencyCode: themeManager.currencyCode, style: .caption)
                    }
                    .foregroundStyle(themeManager.secondaryColor)
                }
            }
            .padding(16)
        }
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 16, y: 8)
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
                    // Image Carousel or Hero
                    if launch.imageURLs.isEmpty {
                        ProjectHeroImage(
                            primaryColor: themeManager.primaryColor,
                            secondaryColor: themeManager.secondaryColor,
                            icon: "sparkles",
                            title: launch.name.uppercased(),
                            height: 260
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .padding(.horizontal, 20)
                    } else {
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
                    }

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
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.06), radius: 12, y: 6)
                    )
                    .padding(.horizontal, 20)

                    // Amenities
                    if !launch.amenitiesList.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            SectionHeader(title: "Amenities", icon: "sparkles")
                            FlowLayout(spacing: 8) {
                                ForEach(launch.amenitiesList, id: \.self) { amenity in
                                    Text(amenity)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundStyle(themeManager.primaryColor)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 7)
                                        .background(
                                            Capsule().fill(themeManager.primaryColor.opacity(0.08))
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
                            : AnyShapeStyle(LinearGradient(
                                colors: [themeManager.secondaryColor.opacity(0.3), themeManager.secondaryColor.opacity(0.15)],
                                startPoint: .leading, endPoint: .trailing
                            ))
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
                .foregroundStyle(themeManager.secondaryColor)
                .frame(width: 24)
            Text(label)
                .foregroundStyle(.brandGray)
            Spacer()
            Text(value)
                .fontWeight(.medium)
                .foregroundStyle(.brandCharcoal)
        }
        .font(.system(size: 15))
    }
}
