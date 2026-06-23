import Foundation
import SwiftUI
import Combine

struct HomeContainerView: View {

    @State private var selectedTab:
    AppTab = .home

    var body: some View {

        NavigationStack {

            ZStack(alignment: .bottom) {

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

                FloatingTabBar(

                    selectedTab:

                    $selectedTab

                )
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
    }
}
