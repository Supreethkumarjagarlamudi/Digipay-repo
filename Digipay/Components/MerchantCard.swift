import SwiftUI

struct MerchantCard: View {

    let merchant:
    NearbyMerchant

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: 8
        ) {

            Text(
                merchant.business_name
            )
            .font(.headline)

            Text(
                merchant.category
            )
            .foregroundColor(
                AppColors.secondaryText
            )

            Text(
                "\(merchant.distance, specifier: "%.2f") km away"
            )
            .font(.caption)
            .foregroundColor(
                AppColors.primaryBlue
            )
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .padding()

        .background(
            AppColors.cardBackground
        )

        .cornerRadius(20)
    }
}
