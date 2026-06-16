import SwiftUI

struct RootView: View {

    @EnvironmentObject
    private var session: SessionManager

    var body: some View {

        Group {

            // MARK: ONBOARDING

            if !session.hasSeenOnboarding {

                OnboardingView()

            }

            // MARK: AUTHENTICATION

            else if !session.isLoggedIn {

                RoleSelectionView()

            }

            // MARK: CUSTOMER

            else if session.role == .customer {

                if session.profileCompleted {

                    HomeContainerView()

                } else {

                    ProfileSetupView()

                }

            }

            // MARK: MERCHANT

            else {

                if session.profileCompleted {

                    MerchantHomeView()

                } else {

                    MerchantBasicInfoView()

                }

            }

        }
        .animation(
            .easeInOut,
            value: session.isLoggedIn
        )

    }

}

#Preview {

    RootView()
        .environmentObject(
            SessionManager.shared
        )

}
