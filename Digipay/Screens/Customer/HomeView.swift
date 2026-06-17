import SwiftUI

struct HomeView: View {

    @StateObject
    private var homeVM = HomeViewModel()
    
    @StateObject
    private var walletVM = WalletViewModel()

    @State private var showAllMerchants = false
    
    @StateObject
    private var locationManager = CustomerLocationManager()
    
    @State private var selectedCategory: String? = nil
    
    @EnvironmentObject
    private var session: SessionManager

    @State private var pulseScale: CGFloat = 1.0

    private let categories = [
        "Cafe",
        "Restaurant",
        "Medical",
        "Grocery",
        "Retail",
        "Shopping",
        "Other"
    ]
    
    private var filteredMerchants: [NearbyMerchant] {
        if let category = selectedCategory {
            return homeVM.merchants.filter { $0.category.lowercased() == category.lowercased() }
        }
        return homeVM.merchants
    }

    var body: some View {
        ZStack {
            AppColors.primaryBackground
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    
                    // 1. Personalized Header
                    headerSection
                    
                    // 2. Proximity Wallet Hero Card
                    walletHeroCard
                    
                    // 3. Best Match curates section
                    if homeVM.isLoading {
                        ProgressView()
                            .tint(AppColors.primaryBlue)
                            .padding(.vertical)
                    } else if let merchant = filteredMerchants.first {
                        bestMatchSection(merchant)
                    } else if selectedCategory != nil {
                        emptyCategoryState
                    }
                    
                    // 4. Quick Categories
                    categorySection
                    
                    // 5. Nearby Merchants list
                    merchantSection
                }
                .padding(.top, 20)
                .padding(.bottom, 180)
            }
            .refreshable {
                await refreshData()
            }
        }
        .onAppear {
            locationManager.requestLocation()
            Task {
                await session.fetchAndSyncProfile()
                await walletVM.loadAnalytics()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("WalletTransactionCreated"))) { _ in
            Task {
                await walletVM.loadAnalytics()
                if locationManager.locationReady {
                    await homeVM.loadRecommendations(
                        latitude: locationManager.latitude,
                        longitude: locationManager.longitude,
                        heading: locationManager.heading,
                        speed: locationManager.speed
                    )
                }
            }
        }
        .onChange(of: locationManager.locationReady) { _, ready in
            if ready {
                Task {
                    await homeVM.loadRecommendations(
                        latitude: locationManager.latitude,
                        longitude: locationManager.longitude,
                        heading: locationManager.heading,
                        speed: locationManager.speed
                    )
                }
            }
        }
    }
    
    private func refreshData() async {
        Task {
            await walletVM.loadAnalytics()
        }
        if locationManager.locationReady {
            await homeVM.loadRecommendations(
                latitude: locationManager.latitude,
                longitude: locationManager.longitude,
                heading: locationManager.heading,
                speed: locationManager.speed
            )
        }
    }
}

// MARK: - HEADER
extension HomeView {
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                let firstName = session.fullName.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: " ").first ?? "there"
                Text("Hi, \(firstName) 👋")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(AppColors.primaryText)
                
                Text("📍 \(locationManager.city.isEmpty ? "Locating position..." : "\(locationManager.city), \(locationManager.state)")")
                    .font(.subheadline)
                    .foregroundColor(AppColors.secondaryText)
            }
            Spacer()
            
            // Profile Initials Badge
            Circle()
                .fill(
                    LinearGradient(
                        colors: [AppColors.primaryBlue, AppColors.secondaryCyan],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 48, height: 48)
                .overlay {
                    let initials = session.fullName.components(separatedBy: " ").compactMap { $0.first }.map { String($0) }.joined()
                    Text(initials.isEmpty ? "DP" : initials.prefix(2).uppercased())
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
        }
        .padding(.horizontal)
    }
}

// MARK: - WALLET HERO CARD
extension HomeView {
    private var walletHeroCard: some View {
        VStack(spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("REMAINING UPI BUDGET")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white.opacity(0.75))
                    
                    let remaining = session.monthlyBudget - walletVM.spentThisMonth
                    Text("₹\(remaining, specifier: "%.2f")")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                }
                Spacer()
                
                // Pulsing Radar indicator (QR-less Context Match telemetry active indicator)
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.12))
                        .frame(width: 50, height: 50)
                        .scaleEffect(pulseScale)
                        .opacity(Double(2.0 - pulseScale))
                        .onAppear {
                            withAnimation(Animation.easeInOut(duration: 1.8).repeatForever(autoreverses: false)) {
                                pulseScale = 2.0
                            }
                        }
                    
                    Circle()
                        .fill(Color.white.opacity(0.18))
                        .frame(width: 38, height: 38)
                    
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .foregroundColor(.white)
                        .font(.subheadline)
                }
            }
            
            Divider()
                .background(Color.white.opacity(0.2))
            
            HStack {
                Text("Total Limit: ₹\(session.monthlyBudget, specifier: "%.2f")")
                    .font(.caption.bold())
                    .foregroundColor(.white.opacity(0.95))
                Spacer()
                
                Button {
                    locationManager.requestLocation()
                    Task {
                        await refreshData()
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.clockwise")
                            .font(.caption)
                        Text("Sync Info")
                            .font(.caption.bold())
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.16))
                    .cornerRadius(10)
                }
            }
        }
        .padding(22)
        .background(
            LinearGradient(
                colors: [AppColors.primaryBlue, AppColors.secondaryCyan],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(26)
        .shadow(color: AppColors.primaryBlue.opacity(0.25), radius: 10, y: 5)
        .padding(.horizontal)
    }
}

// MARK: - BEST PROXIMITY MATCH
extension HomeView {
    private func bestMatchSection(_ merchant: NearbyMerchant) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Recommended Merchant")
                .font(.headline)
                .foregroundColor(AppColors.primaryText)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.caption2)
                        Text("Auto-Identified")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundColor(AppColors.successGreen)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(AppColors.successGreen.opacity(0.12))
                    .cornerRadius(8)
                    
                    Spacer()
                    
                    Text("\(Int(merchant.score))% Match")
                        .font(.caption.bold())
                        .foregroundColor(AppColors.primaryBlue)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(merchant.business_name)
                        .font(.title3.bold())
                        .foregroundColor(AppColors.primaryText)
                    
                    Text(merchant.category)
                        .font(.subheadline)
                        .foregroundColor(AppColors.secondaryText)
                }
                
                if let reason = merchant.ai_reason {
                    Text(reason)
                        .font(.footnote)
                        .foregroundColor(AppColors.secondaryText)
                        .lineLimit(2)
                        .lineSpacing(4)
                }
                
                HStack {
                    Label(String(format: "%.2f km away", merchant.distance), systemImage: "location.fill")
                        .font(.caption)
                        .foregroundColor(AppColors.tertiaryText)
                    
                    Spacer()
                    
                    NavigationLink {
                        AmountEntryView(merchant: merchant)
                    } label: {
                        HStack(spacing: 6) {
                            Text("Pay Now")
                                .fontWeight(.bold)
                            Image(systemName: "arrow.right")
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(AppColors.primaryBlue)
                        .cornerRadius(12)
                    }
                }
            }
            .padding(20)
            .background(AppColors.cardBackground)
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.04), radius: 10, y: 5)
            .padding(.horizontal)
        }
    }
    
    private var emptyCategoryState: some View {
        VStack(spacing: 12) {
            Image(systemName: "storefront.fill")
                .font(.system(size: 40))
                .foregroundColor(AppColors.secondaryText)
            
            Text("No merchants found in \(selectedCategory ?? "")")
                .font(.subheadline)
                .foregroundColor(AppColors.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(AppColors.cardBackground)
        .cornerRadius(20)
        .padding(.horizontal)
    }
}

// MARK: - CATEGORIES
extension HomeView {
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Categories")
                .font(.headline)
                .foregroundColor(AppColors.primaryText)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(categories, id: \.self) { category in
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0)) {
                                if selectedCategory == category {
                                    selectedCategory = nil
                                } else {
                                    selectedCategory = category
                                }
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Text(getCategoryEmoji(category))
                                Text(category)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(selectedCategory == category ? .white : AppColors.primaryText)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(selectedCategory == category ? AppColors.primaryBlue : AppColors.cardBackground)
                            .cornerRadius(14)
                            .shadow(color: selectedCategory == category ? AppColors.primaryBlue.opacity(0.2) : Color.clear, radius: 6, y: 3)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private func getCategoryEmoji(_ cat: String) -> String {
        switch cat.lowercased() {
        case "cafe": return "☕️"
        case "restaurant": return "🍔"
        case "medical": return "🏥"
        case "grocery": return "🛒"
        case "retail": return "🛍️"
        case "shopping": return "👔"
        default: return "✨"
        }
    }
}

// MARK: - MERCHANT LIST
extension HomeView {
    private var merchantSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Nearby Merchants")
                    .font(.headline)
                    .foregroundColor(AppColors.primaryText)
                
                Spacer()
                
                Button {
                    showAllMerchants = true
                } label: {
                    Text("View All")
                        .font(.subheadline.bold())
                        .foregroundColor(AppColors.primaryBlue)
                }
            }
            .padding(.horizontal)
            .sheet(isPresented: $showAllMerchants) {
                NavigationStack {
                    MerchantListView(merchants: homeVM.merchants)
                }
            }
            
            if filteredMerchants.dropFirst().isEmpty {
                Text("No additional merchants nearby.")
                    .font(.subheadline)
                    .foregroundColor(AppColors.secondaryText)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                VStack(spacing: 12) {
                    ForEach(Array(filteredMerchants.dropFirst())) { merchant in
                        NavigationLink {
                            MerchantDetailView(merchant: merchant)
                        } label: {
                            merchantCard(merchant)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
    
    private func merchantCard(_ merchant: NearbyMerchant) -> some View {
        HStack(spacing: 16) {
            Circle()
                .fill(AppColors.primaryBlue.opacity(0.1))
                .frame(width: 44, height: 44)
                .overlay {
                    Text(getCategoryEmoji(merchant.category))
                        .font(.title3)
                }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(merchant.business_name)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.primaryText)
                
                Text(merchant.category)
                    .font(.caption)
                    .foregroundColor(AppColors.secondaryText)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Int(merchant.score))% Match")
                    .font(.caption.bold())
                    .foregroundColor(AppColors.successGreen)
                
                Text(String(format: "%.2f km", merchant.distance))
                    .font(.caption2)
                    .foregroundColor(AppColors.secondaryText)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(18)
        .padding(.horizontal)
    }
}
