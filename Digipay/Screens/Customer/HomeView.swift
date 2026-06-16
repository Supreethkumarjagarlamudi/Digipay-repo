import SwiftUI

struct HomeView: View {

    @StateObject
    private var homeVM = HomeViewModel()

    @State private var showAllMerchants = false
    @StateObject
    private var locationManager =
    CustomerLocationManager()

    private let categories = [
        "Cafe",
        "Restaurant",
        "Medical",
        "Grocery"
    ]

    var body: some View {

        ZStack {

            AppColors.primaryBackground
                .ignoresSafeArea()

            ScrollView(
                showsIndicators: false
            ) {

                VStack(
                    spacing: 24
                ) {

                    headerSection

                    locationCard

                    if homeVM.isLoading {

                        ProgressView()
                            .padding(.top)
                    }

                    if let merchant =
                        homeVM.merchants.first {

                        NavigationLink {

                            MerchantDetailView(
                                merchant: merchant
                            )

                        } label: {

                            recommendationCard(
                                merchant
                            )
                        }
                        .buttonStyle(.plain)
                    }

                    categorySection

                    merchantSection
                }
                .padding(.top, 20)
                .padding(.bottom, 180)
            }
        }
        .onAppear {

            locationManager
                .requestLocation()
        }
        .onChange(
            of: locationManager.locationReady
        ) { _, ready in

            if ready {

                Task {

                    await homeVM
                        .loadRecommendations(

                            latitude:
                                locationManager.latitude,

                            longitude:
                                locationManager.longitude,

                            heading:
                                locationManager.heading,

                            speed:
                                locationManager.speed
                        )
                }
            }
        }
    }
}

// MARK: HEADER

extension HomeView {

    private var headerSection: some View {

        VStack(
            alignment: .leading,
            spacing: 6
        ) {

            HStack {

                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {

                    Text("Good Afternoon 👋")
                        .font(.subheadline)
                        .foregroundColor(
                            AppColors.secondaryText
                        )

                    Text("Discover Nearby")
                        .font(
                            .system(
                                size: 34,
                                weight: .bold
                            )
                        )
                }

                Spacer()

                Image("app_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: 54,
                        height: 54
                    )
            }

            Text(
                "Smart merchant recommendations powered by context awareness."
            )
            .font(.footnote)
            .foregroundColor(
                AppColors.secondaryText
            )
        }
        .padding(.horizontal)
    }

    private var locationCard: some View {

        HStack {

            ZStack {

                Circle()
                    .fill(
                        AppColors.secondaryCyan.opacity(0.15)
                    )
                    .frame(
                        width: 50,
                        height: 50
                    )

                Image(
                    systemName:
                    "location.fill"
                )
                .foregroundColor(
                    AppColors.secondaryCyan
                )
            }

            VStack(
                alignment: .leading,
                spacing: 4
            ) {

                Text("Location Active")
                    .fontWeight(
                        .semibold
                    )

                Text(
                    locationManager.city.isEmpty
                    ? "Detecting location..."
                    : "\(locationManager.city), \(locationManager.state)"
                )
                .font(.caption)
                .foregroundColor(
                    AppColors.secondaryText
                )
            }

            Spacer()

            Circle()
                .fill(
                    AppColors.successGreen
                )
                .frame(
                    width: 12,
                    height: 12
                )
        }
        .padding()

        .background(
            AppColors.cardBackground
        )

        .cornerRadius(24)

        .padding(.horizontal)
    }

    private var categorySection: some View {

        VStack(
            alignment: .leading,
            spacing: 14
        ) {

            Text("Quick Categories")
                .font(
                    .title3.bold()
                )
                .padding(.horizontal)

            ScrollView(
                .horizontal,
                showsIndicators: false
            ) {

                HStack(
                    spacing: 12
                ) {

                    ForEach(
                        categories,
                        id: \.self
                    ) { category in

                        Text(category)
                            .fontWeight(.medium)

                            .padding(
                                .horizontal,
                                18
                            )

                            .padding(
                                .vertical,
                                10
                            )

                            .background(
                                AppColors.cardBackground
                            )

                            .cornerRadius(16)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    private var merchantSection: some View {

        VStack(
            alignment: .leading,
            spacing: 14
        ) {

            HStack {

                Text(
                    "Nearby Merchants"
                )
                .font(
                    .title3.bold()
                )

                Spacer()

                Button {

                    showAllMerchants = true

                } label: {

                    Text("View All")
                        .foregroundColor(
                            AppColors.primaryBlue
                        )
                }
            }
            .padding(.horizontal)
            .sheet(
                isPresented:
                    $showAllMerchants
            ) {

                NavigationStack {

                    MerchantListView(
                        merchants:
                            homeVM.merchants
                    )
                }
            }

            ForEach(
                Array(
                    homeVM.merchants.dropFirst()
                )
            ) { merchant in

                NavigationLink {

                    MerchantDetailView(
                        merchant: merchant
                    )

                } label: {

                    merchantCard(
                        merchant
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: COMPONENTS

extension HomeView {

    private func recommendationCard(
        _ merchant: NearbyMerchant
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 18
        ) {

            HStack {

                Label(
                    "Best Match",
                    systemImage:
                    "sparkles"
                )

                Spacer()

                Text(
                    "\(Int(merchant.score))%"
                )
                .fontWeight(.bold)
            }

            Text(
                merchant.business_name
            )
            .font(
                .system(
                    size: 28,
                    weight: .bold
                )
            )

            Text(
                merchant.category
            )

            if let reason = merchant.ai_reason {
                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .font(.caption)
                    Text(reason)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundColor(.white.opacity(0.95))
            }

            HStack {

                Label(
                    "\(merchant.distance, specifier: "%.2f") km",
                    systemImage:
                    "location"
                )

                Spacer()

                Label(
                    "AI Ranked",
                    systemImage:
                    "brain"
                )
            }
            .font(.caption)

            Button {
                Task {
                    try? await WalletService.shared.createTransaction(
                        merchantName: merchant.business_name,
                        amount: 100.0,
                        category: merchant.category,
                        latitude: locationManager.latitude,
                        longitude: locationManager.longitude,
                        heading: locationManager.heading,
                        speed: locationManager.speed
                    )
                }
                UPIManager.shared
                    .openUPILink(
                        deepLink:
                            merchant.upi_deep_link
                    )

            } label: {

                Text("Pay Now")
                    .fontWeight(.bold)

                    .foregroundColor(
                        AppColors.primaryBlue
                    )

                    .frame(
                        maxWidth: .infinity
                    )

                    .frame(
                        height: 56
                    )

                    .background(
                        Color.white
                    )

                    .cornerRadius(16)
            }
        }
        .foregroundColor(.white)

        .padding()

        .background(

            LinearGradient(

                colors: [

                    AppColors.primaryBlue,

                    AppColors.secondaryCyan
                ],

                startPoint:
                    .topLeading,

                endPoint:
                    .bottomTrailing
            )
        )

        .cornerRadius(28)

        .padding(.horizontal)
    }

    private func merchantCard(
        _ merchant: NearbyMerchant
    ) -> some View {

        HStack {

            VStack(
                alignment: .leading,
                spacing: 6
            ) {

                Text(
                    merchant.business_name
                )
                .fontWeight(.bold)

                Text(
                    merchant.category
                )
                .font(.caption)

                .foregroundColor(
                    AppColors.secondaryText
                )
            }

            Spacer()

            VStack(
                alignment: .trailing,
                spacing: 6
            ) {

                Text(
                    "\(Int(merchant.score))%"
                )
                .fontWeight(.bold)

                .foregroundColor(
                    AppColors.successGreen
                )

                Text(
                    "\(merchant.distance, specifier: "%.2f") km"
                )
                .font(.caption)
            }
        }
        .padding()

        .background(
            AppColors.cardBackground
        )

        .cornerRadius(22)

        .padding(.horizontal)
    }
}
