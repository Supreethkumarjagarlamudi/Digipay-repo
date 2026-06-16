import SwiftUI

struct OnboardingPage: View {

    let item: OnboardingItem

    var body: some View {

        VStack(spacing: 0) {

            Spacer()
                .frame(height: 10)


            Image(item.image)
                .resizable()
                .scaledToFit()
                .frame(height: 360)

            Spacer()
                .frame(height: 18)


            Spacer()
                .frame(height: 20)


            VStack(spacing: 16) {

                Text(item.title)
                    .font(
                        .system(
                            size: 24,
                            weight: .bold
                        )
                    )
                    .foregroundColor(AppColors.primaryText)
                    .multilineTextAlignment(.center)

                Text(item.subtitle)
                    .font(.system(size: 17))
                    .foregroundColor(AppColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .padding(.horizontal, 36)
            }

            Spacer()
        }
    }
}
