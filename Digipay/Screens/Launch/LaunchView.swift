import SwiftUI

struct LaunchView: View {

    @State private var navigate = false

    var body: some View {

        Group {

            if navigate {

                RootView()

            } else {

                launchContent

            }

        }
        .animation(.easeInOut, value: navigate)
        .onAppear {

            NetworkPermissionManager
                .requestLocalNetworkAccess()

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {

                navigate = true

            }
        }
    }
}

extension LaunchView {

    private var launchContent: some View {

        ZStack {

            AppColors.primaryBackground
                .ignoresSafeArea()

            VStack {

                Spacer()

                VStack(spacing: 18) {

                    Image("app_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120)

                    Text("DIGIPAY")
                        .font(.system(size: 46, weight: .bold))

                    Text("Identify merchants around you instantly and pay with UPI in just a tap.")
                        .foregroundColor(AppColors.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                }

                Spacer()

                Image("launch_bg")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 470)
                    .ignoresSafeArea(edges: .bottom)

            }

        }

    }

}

#Preview{
    LaunchView()
}
