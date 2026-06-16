import SwiftUI

struct MerchantDetailView: View {

    let merchant: NearbyMerchant

    @StateObject
    private var locationManager = CustomerLocationManager()

    var body: some View {

        ZStack {

            AppColors.primaryBackground
                .ignoresSafeArea()

            ScrollView {

                VStack(
                    spacing: 24
                ) {

                    RoundedRectangle(
                        cornerRadius: 24
                    )
                    .fill(

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
                    .frame(height: 220)

                    .overlay {

                        VStack(
                            spacing: 12
                        ) {

                            Image(
                                systemName:
                                "storefront.fill"
                            )
                            .font(
                                .system(
                                    size: 60
                                )
                            )
                            .foregroundColor(
                                .white
                            )

                            Text(
                                merchant.business_name
                            )
                            .font(
                                .title.bold()
                            )
                            .foregroundColor(
                                .white
                            )

                            Text(
                                merchant.category
                            )
                            .foregroundColor(
                                .white.opacity(0.9)
                            )
                        }
                    }

                    infoCard

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
                            .fontWeight(
                                .bold
                            )
                            .foregroundColor(
                                .white
                            )
                            .frame(
                                maxWidth: .infinity
                            )
                            .frame(height: 58)
                            .background(
                                AppColors.primaryBlue
                            )
                            .cornerRadius(18)
                    }
                }
                .padding()
            }
        }
    }

    private var infoCard: some View {

        VStack(
            spacing: 18
        ) {

            detailRow(
                icon: "star.fill",
                title: "Match Score",
                value:
                    "\(Int(merchant.score))%"
            )

            detailRow(
                icon: "location.fill",
                title: "Distance",
                value:
                    String(
                            format: "%.2f km",
                            merchant.distance
                        )
            )

            detailRow(
                icon: "tag.fill",
                title: "Category",
                value:
                    merchant.category
            )
        }
        .padding()

        .background(
            AppColors.cardBackground
        )

        .cornerRadius(24)
    }

    private func detailRow(

        icon: String,

        title: String,

        value: String

    ) -> some View {

        HStack {

            Image(
                systemName: icon
            )
            .foregroundColor(
                AppColors.primaryBlue
            )

            Text(title)

            Spacer()

            Text(value)
                .fontWeight(.semibold)
        }
    }
}
