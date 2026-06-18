import SwiftUI

struct FloatingTabBar: View {

    @Binding var selectedTab: AppTab

    var body: some View {

        HStack {

            navButton(
                icon: "house.fill",
                title: "Home",
                tab: .home
            )

            Spacer()

            navButton(
                icon: "wallet.pass.fill",
                title: "Wallet",
                tab: .wallet
            )

            Spacer()

            navButton(
                icon: "map.fill",
                title: "Discover",
                tab: .Discover
            )

            Spacer()

            navButton(
                icon: "person.fill",
                title: "Profile",
                tab: .profile
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)

        .background(
            AppColors.cardBackground
        )

        .cornerRadius(24)

        .shadow(
            color: .black.opacity(0.08),
            radius: 12,
            y: 4
        )

        .padding(.horizontal)
        .padding(.bottom, 12)
    }

    private func navButton(
        icon: String,
        title: String,
        tab: AppTab
    ) -> some View {

        Button {

            selectedTab = tab

        } label: {

            VStack(spacing: 4) {

                Image(systemName: icon)
                    .font(.system(size: 20))

                Text(title)
                    .font(.caption2)
            }
            .foregroundColor(
                selectedTab == tab
                ? AppColors.primaryBlue
                : AppColors.secondaryText
            )
        }
        .accessibilityIdentifier("tab_\(title.lowercased())")
    }
}
