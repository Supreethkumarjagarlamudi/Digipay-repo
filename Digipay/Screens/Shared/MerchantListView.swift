
import SwiftUI

struct MerchantListView: View {

    let merchants: [NearbyMerchant]

    var body: some View {

        ZStack {

            AppColors.primaryBackground
                .ignoresSafeArea()

            ScrollView {

                LazyVStack(
                    spacing: 16
                ) {

                    ForEach(
                        merchants
                    ) { merchant in

                        VStack(
                            alignment: .leading,
                            spacing: 8
                        ) {

                            Text(
                                merchant.business_name
                            )
                            .font(
                                .headline
                            )

                            Text(
                                merchant.category
                            )
                            .foregroundColor(
                                AppColors.secondaryText
                            )

                            HStack {

                                Label(
                                    "\(Int(merchant.score))%",
                                    systemImage:
                                    "star.fill"
                                )

                                Spacer()

                                Text(
                                    "\(merchant.distance, specifier: "%.2f") km"
                                )
                            }
                            .font(.caption)
                        }
                        .padding()

                        .background(
                            AppColors.cardBackground
                        )

                        .cornerRadius(20)
                    }
                }
                .padding()
            }
        }
        .navigationTitle(
            "All Merchants"
        )
        .navigationBarTitleDisplayMode(
            .large
        )
    }
}

