import SwiftUI


struct OnboardingView: View {
    
    @EnvironmentObject
    private var session: SessionManager
    
    @AppStorage("hasSeenOnboarding")
    private var hasSeenOnboarding = false

    @State private var currentPage = 0

    let onboardingItems = [

        OnboardingItem(
            image: "onboarding_1",
            title: "Find Merchants Intelligently",
            subtitle: "DIGIPIN technology helps you discover the right merchant around you without scanning any QR."
        ),

        OnboardingItem(
            image: "onboarding_2",
            title: "Pay Instantly with UPI",
            subtitle: "Secure UPI deep linking lets you make payments in one tap with no hassle."
        ),

        OnboardingItem(
            image: "onboarding_3",
            title: "Track, Analyze, Save",
            subtitle: "Smart expense tracking and categorization help you manage spending better."
        )
    ]

    var body: some View {

        ZStack {

            AppColors.primaryBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {

                // MARK: TOP BAR

                HStack {

                    Spacer()

                    Button {
                        hasSeenOnboarding = true
                        session.completeOnboarding()
                    } label: {
                        Text("Skip")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(AppColors.primaryBlue)
                    }
                }
                .padding(.horizontal, 28)
                .padding(.top, 14)

                // MARK: TAB VIEW

                TabView(selection: $currentPage) {

                    ForEach(0..<onboardingItems.count, id: \.self) { index in

                        OnboardingPage(
                            item: onboardingItems[index]
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // MARK: BOTTOM CONTROLS

                VStack(spacing: 30) {

                    // DOTS

                    HStack(spacing: 9) {

                        ForEach(0..<onboardingItems.count, id: \.self) { index in

                            Circle()
                                .fill(
                                    currentPage == index
                                    ? AppColors.primaryBlue
                                    : Color.gray.opacity(0.25)
                                )
                                .frame(
                                    width: currentPage == index ? 10 : 8,
                                    height: currentPage == index ? 10 : 8
                                )
                                .animation(
                                    .easeInOut(duration: 0.2),
                                    value: currentPage
                                )
                        }
                    }

                    // MARK: BUTTON CONTAINER

                    ZStack {

                        RoundedRectangle(cornerRadius: 34)
                            .fill(AppColors.cardBackground)
                            .frame(height: 72)
                            .shadow(
                                color: .black.opacity(0.04),
                                radius: 18,
                                y: 8
                            )

                        HStack {

                            // BACK BUTTON

                            if currentPage > 0 {

                                Button {

                                    withAnimation {

                                        currentPage -= 1
                                    }

                                } label: {

                                    Image(systemName: "arrow.left")
                                        .font(
                                            .system(
                                                size: 18,
                                                weight: .bold
                                            )
                                        )
                                        .foregroundColor(AppColors.primaryText)
                                        .frame(width: 52, height: 52)
                                        .background(
                                            Circle()
                                                .fill(
                                                    AppColors.secondaryBackground
                                                )
                                        )
                                }
                            }

                            Spacer()

                            // NEXT BUTTON

                            Button {

                                if currentPage < onboardingItems.count - 1 {

                                    withAnimation {

                                        currentPage += 1
                                    }
                                } else {
                                    hasSeenOnboarding = true
                                    session.completeOnboarding()
                                }

                            } label: {

                                ZStack {

                                    if currentPage == onboardingItems.count - 1 {

                                        Text("Get Started")
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)

                                    } else {

                                        Image(systemName: "arrow.right")
                                            .font(
                                                .system(
                                                    size: 20,
                                                    weight: .bold
                                                )
                                            )
                                            .foregroundColor(.white)
                                    }
                                }
                                .frame(
                                    width: currentPage == onboardingItems.count - 1 ? 190 : 52,
                                    height: 52
                                )
                                .background(AppColors.primaryBlue)
                                .clipShape(Capsule())
                                .shadow(
                                    color: AppColors.primaryBlue.opacity(0.25),
                                    radius: 12,
                                    y: 6
                                )
                            }
                        }
                        .padding(.horizontal, 10)
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 32)
            }
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(SessionManager.shared)
}
