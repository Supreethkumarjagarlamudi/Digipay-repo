import Foundation
import SwiftUI
import Combine

struct HomeContainerView: View {

    @State private var selectedTab:
    AppTab = .home

    var body: some View {

        NavigationStack {

            ZStack {

                AppColors.primaryBackground
                    .ignoresSafeArea()

                Group {

                    switch selectedTab {

                    case .home:
                        HomeView()

                    case .wallet:
                        WalletView()

                    case .Discover:
                        DiscoverView()

                    case .profile:
                        ProfileView()
                    }
                }

                .overlay(

                    alignment: .bottom

                ) {

                    FloatingTabBar(

                        selectedTab:

                        $selectedTab

                    )

                }
            }
        }
    }
}
