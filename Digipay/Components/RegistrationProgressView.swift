import SwiftUI

struct RegistrationProgressView: View {

    let currentStep: Int
    let totalSteps: Int

    var progress: Double {

        Double(currentStep) /
        Double(totalSteps)
    }

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: 8
        ) {

            Text(
                "Step \(currentStep) of \(totalSteps)"
            )
            .font(.subheadline)
            .foregroundColor(
                AppColors.secondaryText
            )

            ProgressView(
                value: progress
            )
            .tint(
                AppColors.primaryBlue
            )
        }
    }
}

#Preview {

    RegistrationProgressView(
        currentStep: 1,
        totalSteps: 3
    )
}
