import SwiftUI
import MapKit

struct DiscoverView: View {

    @StateObject
    private var homeVM = HomeViewModel()

    @StateObject
    private var locationManager = CustomerLocationManager()

    @State private var cameraPosition = MapCameraPosition.automatic
    @State private var searchText = ""
    @State private var selectedCategory = ""
    @State private var selectedMerchant: NearbyMerchant? = nil

    private let categories = ["All", "Cafe", "Restaurant", "Medical", "Grocery", "Electronics"]

    private var filteredMerchants: [NearbyMerchant] {
        homeVM.merchants.filter { merchant in
            guard merchant.latitude != nil, merchant.longitude != nil else { return false }
            let matchesCategory = selectedCategory.isEmpty || selectedCategory == "All" || merchant.category == selectedCategory
            let matchesSearch = searchText.isEmpty || 
                merchant.business_name.localizedCaseInsensitiveContains(searchText) || 
                merchant.category.localizedCaseInsensitiveContains(searchText)
            return matchesCategory && matchesSearch
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // MARK: MAP
                Map(position: $cameraPosition) {
                    Marker(
                        "You",
                        systemImage: "person.circle.fill",
                        coordinate: CLLocationCoordinate2D(
                            latitude: locationManager.latitude,
                            longitude: locationManager.longitude
                        )
                    )
                    .tint(AppColors.primaryBlue)

                    ForEach(filteredMerchants) { merchant in
                        Annotation(
                            merchant.business_name,
                            coordinate: CLLocationCoordinate2D(latitude: merchant.latitude!, longitude: merchant.longitude!)
                        ) {
                            Button {
                                withAnimation(.spring()) {
                                    selectedMerchant = merchant
                                    cameraPosition = .region(MKCoordinateRegion(
                                        center: CLLocationCoordinate2D(latitude: merchant.latitude!, longitude: merchant.longitude!),
                                        span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                                    ))
                                }
                            } label: {
                                VStack(spacing: 4) {
                                    Image(systemName: "storefront.fill")
                                        .font(.system(size: 16, weight: .bold))
                                        .padding(10)
                                        .background(
                                            selectedMerchant?.id == merchant.id
                                            ? AppColors.primaryBlue
                                            : AppColors.cardBackground
                                        )
                                        .foregroundColor(
                                            selectedMerchant?.id == merchant.id
                                            ? .white
                                            : AppColors.primaryBlue
                                        )
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(AppColors.primaryBlue.opacity(0.5), lineWidth: 2)
                                        )
                                        .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
                                }
                            }
                        }
                    }
                }
                .ignoresSafeArea()

                // MARK: TOP SEARCH & FILTERS
                VStack {
                    searchAndFilterHeader
                    Spacer()
                }

                // MARK: BOTTOM PANEL
                VStack {
                    Spacer()
                    if let merchant = selectedMerchant {
                        selectedMerchantCard(merchant)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    } else {
                        merchantSheet
                    }
                }
            }
            .onAppear {
                locationManager.requestLocation()
            }
            .onChange(of: locationManager.locationReady) { _, ready in
                if ready {
                    cameraPosition = .region(
                        MKCoordinateRegion(
                            center: CLLocationCoordinate2D(
                                latitude: locationManager.latitude,
                                longitude: locationManager.longitude
                            ),
                            span: MKCoordinateSpan(
                                latitudeDelta: 0.01,
                                longitudeDelta: 0.01
                            )
                        )
                    )
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
    }
}

// MARK: - TOP HEADER VIEW
extension DiscoverView {
    private var searchAndFilterHeader: some View {
        VStack(spacing: 12) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(AppColors.secondaryText)
                
                TextField("Search merchants, categories...", text: $searchText)
                    .tint(AppColors.primaryBlue)
                
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppColors.secondaryText)
                    }
                }
            }
            .padding()
            .background(AppColors.cardBackground.opacity(0.95))
            .cornerRadius(18)
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            .padding(.horizontal)
            .padding(.top, 10)

            // Category Chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(categories, id: \.self) { category in
                        Button {
                            withAnimation(.spring()) {
                                selectedCategory = (category == "All") ? "" : category
                            }
                        } label: {
                            Text(category)
                                .font(.system(size: 14, weight: .semibold))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    (selectedCategory == category || (category == "All" && selectedCategory.isEmpty))
                                    ? AppColors.primaryBlue
                                    : AppColors.cardBackground.opacity(0.95)
                                )
                                .foregroundColor(
                                    (selectedCategory == category || (category == "All" && selectedCategory.isEmpty))
                                    ? .white
                                    : AppColors.primaryText
                                )
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(AppColors.borderColor.opacity(0.15), lineWidth: 1)
                                )
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - MERCHANT DETAIL CARD
extension DiscoverView {
    private func selectedMerchantCard(_ merchant: NearbyMerchant) -> some View {
        VStack(spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(merchant.business_name)
                            .font(.title3.bold())
                        Spacer()
                        Button {
                            withAnimation {
                                selectedMerchant = nil
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title3)
                                .foregroundColor(AppColors.secondaryText)
                        }
                    }
                    
                    Text(merchant.category)
                        .font(.subheadline)
                        .foregroundColor(AppColors.secondaryText)
                    
                    if let reason = merchant.ai_reason {
                        HStack(spacing: 6) {
                            Image(systemName: "sparkles")
                                .font(.caption)
                                .foregroundColor(AppColors.secondaryCyan)
                            Text(reason)
                                .font(.caption)
                                .foregroundColor(AppColors.secondaryText)
                        }
                        .padding(.top, 4)
                    }
                }
            }

            Divider()

            HStack(spacing: 12) {
                // Distance & Score
                VStack(alignment: .leading, spacing: 4) {
                    Label("\(merchant.distance, specifier: "%.2f") km", systemImage: "location.fill")
                        .font(.caption)
                    Label("\(Int(merchant.score))% confidence", systemImage: "sparkles")
                        .font(.caption)
                        .foregroundColor(AppColors.successGreen)
                }
                
                Spacer()

                // Directions Button
                Button {
                    if let lat = merchant.latitude, let lon = merchant.longitude {
                        openDirectionsInMaps(latitude: lat, longitude: lon, name: merchant.business_name)
                    }
                } label: {
                    Label("Directions", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppColors.primaryBlue)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(AppColors.primaryBlue.opacity(0.12))
                        .cornerRadius(12)
                }

                // Pay Now Button
                NavigationLink {
                    AmountEntryView(merchant: merchant)
                } label: {
                    Text("Pay Now")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(AppColors.primaryBlue)
                        .cornerRadius(12)
                }
            }
        }
        .padding(20)
        .background(AppColors.cardBackground)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
        .padding(.horizontal)
        .padding(.bottom, 100)
    }

    private func openDirectionsInMaps(latitude: Double, longitude: Double, name: String) {
        let nameEncoded = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let url = URL(string: "maps://?q=\(nameEncoded)&ll=\(latitude),\(longitude)")!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

// MARK: - MERCHANT LIST BOTTOM PANEL
extension DiscoverView {
    private var merchantSheet: some View {
        VStack(spacing: 16) {
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 50, height: 5)

            HStack {
                Text("Nearby Merchants")
                    .font(.title3.bold())

                Spacer()

                Text("\(filteredMerchants.count)")
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.primaryBlue)
            }

            if homeVM.isLoading {
                ProgressView()
                    .padding()
            }

            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 12) {
                    ForEach(filteredMerchants) { merchant in
                        Button {
                            withAnimation(.spring()) {
                                selectedMerchant = merchant
                                if let lat = merchant.latitude, let lon = merchant.longitude {
                                    cameraPosition = .region(MKCoordinateRegion(
                                        center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                                        span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                                    ))
                                }
                            }
                        } label: {
                            merchantCard(merchant)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding()
        .frame(height: 280)
        .background(AppColors.primaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .shadow(color: Color.black.opacity(0.1), radius: 10, y: -5)
        .padding(.bottom, 80)
    }

    private func merchantCard(_ merchant: NearbyMerchant) -> some View {
        HStack {
            Circle()
                .fill(AppColors.primaryBlue.opacity(0.12))
                .frame(width: 44, height: 44)
                .overlay {
                    Image(systemName: "storefront.fill")
                        .foregroundColor(AppColors.primaryBlue)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(merchant.business_name)
                    .fontWeight(.bold)
                
                Text(merchant.category)
                    .font(.caption)
                    .foregroundColor(AppColors.secondaryText)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Int(merchant.score))%")
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.successGreen)

                Text(String(format: "%.2f km", merchant.distance))
                    .font(.caption)
                    .foregroundColor(AppColors.secondaryText)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(18)
    }
}
