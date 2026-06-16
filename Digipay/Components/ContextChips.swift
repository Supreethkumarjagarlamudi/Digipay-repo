import SwiftUI

struct ContextChip: View {

    let title: String
    let value: String

    var body: some View {

        VStack(
            spacing: 8
        ) {

            Text(title)
                .font(.caption)
                .foregroundColor(
                    AppColors.secondaryText
                )

            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(
                    AppColors.primaryText
                )
        }
        .frame(
            maxWidth: .infinity
        )
        .padding()
        .background(
            AppColors.cardBackground
        )
        .cornerRadius(20)
    }
}
