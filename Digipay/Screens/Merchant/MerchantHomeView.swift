import SwiftUI

struct MerchantHomeView: View {

    @EnvironmentObject
    private var session: SessionManager

    @StateObject private var dashboardVM = MerchantHomeViewModel()

    var body: some View {

        ZStack {

            AppColors.primaryBackground
                .ignoresSafeArea()

            ScrollView(
                showsIndicators: false
            ) {

                VStack(
                    spacing: 24
                ) {

                    headerSection

                    revenueCard

                    statsSection

                    recentActivitySection

                    statusSection
                    
                    logoutButton
                }
                .padding()
                .padding(.bottom, 40)
            }
            .refreshable {
                await dashboardVM.loadDashboard()
            }
        }
        .onAppear {
            Task {
                await dashboardVM.loadDashboard()
            }
        }
    }
}

// MARK: HEADER
extension MerchantHomeView {

    private var headerSection: some View {

        HStack {

            VStack(
                alignment: .leading,
                spacing: 6
            ) {

                Text(dashboardVM.businessName.isEmpty ? "Merchant Hub" : dashboardVM.businessName)
                    .font(
                        .system(
                            size: 34,
                            weight: .bold
                        )
                    )

                Text(
                    dashboardVM.category.isEmpty ? "Manage your business" : "Category: \(dashboardVM.category)"
                )
                .foregroundColor(
                    AppColors.secondaryText
                )
            }

            Spacer()

            Image("app_logo")
                .resizable()
                .scaledToFit()
                .frame(
                    width: 50,
                    height: 50
                )
        }
    }
}

// MARK: REVENUE CARD
extension MerchantHomeView {

    private var revenueCard: some View {

        VStack(
            alignment: .leading,
            spacing: 16
        ) {

            Text("Today's Revenue")
                .foregroundColor(
                    .white.opacity(0.9)
                )

            Text("₹\(dashboardVM.todayRevenue, specifier: "%.2f")")
                .font(
                    .system(
                        size: 40,
                        weight: .bold
                    )
                )
                .foregroundColor(.white)

            HStack {

                Label(
                    "\(dashboardVM.totalPaymentsCount) Total Payments",
                    systemImage:
                    "arrow.left.arrow.right"
                )

                Spacer()

                Label(
                    "Today",
                    systemImage:
                    "calendar"
                )
            }
            .font(.caption)
            .foregroundColor(.white)
        }
        .padding()

        .frame(maxWidth: .infinity)

        .background(

            LinearGradient(

                colors: [

                    AppColors.primaryBlue,

                    AppColors.secondaryCyan
                ],

                startPoint:
                    .topLeading,

                endPoint:
                    .bottomTrailing
            )
        )

        .cornerRadius(30)
    }
}

// MARK: STATS
extension MerchantHomeView {

    private var statsSection: some View {

        HStack(
            spacing: 14
        ) {

            statCard(
                icon:
                "person.2.fill",
                value:
                "\(dashboardVM.todayCustomers)",
                title:
                "Customers Today"
            )

            statCard(
                icon:
                "chart.bar.fill",
                value:
                "\(dashboardVM.nearbyActivityCount)",
                title:
                "Nearby Activity"
            )
        }
    }

    private func statCard(
        icon: String,
        value: String,
        title: String
    ) -> some View {

        VStack(
            spacing: 10
        ) {

            Image(
                systemName: icon
            )
            .font(.title2)

            .foregroundColor(
                AppColors.primaryBlue
            )

            Text(value)
                .font(
                    .title.bold()
                )

            Text(title)
                .font(.caption)

                .foregroundColor(
                    AppColors.secondaryText
                )
        }
        .frame(maxWidth: .infinity)

        .padding()

        .background(
            AppColors.cardBackground
        )

        .cornerRadius(22)
    }
}

// MARK: RECENT ACTIVITY
extension MerchantHomeView {

    private var recentActivitySection: some View {

        VStack(
            alignment: .leading,
            spacing: 14
        ) {

            Text("Recent Payments")
                .font(
                    .title3.bold()
                )

            if dashboardVM.recentPayments.isEmpty {
                Text("No payments received yet.")
                    .font(.subheadline)
                    .foregroundColor(AppColors.secondaryText)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                ForEach(dashboardVM.recentPayments) { payment in
                    activityRow(
                        customer: "From: \(payment.customer_phone)",
                        amount: String(format: "₹%.2f", payment.amount),
                        timeStr: formatTimestamp(payment.timestamp)
                    )
                }
            }
        }
    }

    private func activityRow(
        customer: String,
        amount: String,
        timeStr: String
    ) -> some View {

        HStack {

            Circle()
                .fill(
                    AppColors.successGreen
                )
                .frame(
                    width: 12,
                    height: 12
                )

            VStack(
                alignment: .leading
            ) {

                Text(customer)
                    .fontWeight(.medium)

                Text(timeStr)
                    .font(.caption)

                    .foregroundColor(
                        AppColors.secondaryText
                    )
            }

            Spacer()

            Text(amount)
                .fontWeight(.bold)
                .foregroundColor(AppColors.successGreen)
        }
        .padding()

        .background(
            AppColors.cardBackground
        )

        .cornerRadius(18)
    }

    private func formatTimestamp(_ isoString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: isoString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateStyle = .none
            outputFormatter.timeStyle = .short
            return outputFormatter.string(from: date)
        }
        
        let fallback = DateFormatter()
        fallback.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let date = fallback.date(from: isoString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateStyle = .none
            outputFormatter.timeStyle = .short
            return outputFormatter.string(from: date)
        }
        
        return "Recent"
    }
}

// MARK: STATUS
extension MerchantHomeView {

    private var statusSection: some View {

        VStack(
            alignment: .leading,
            spacing: 14
        ) {

            Text("Business Status")
                .font(
                    .title3.bold()
                )

            statusCard(
                title:
                "DIGIPIN (\(dashboardVM.digipin))",
                value:
                dashboardVM.digipinStatus
            )

            statusCard(
                title:
                "UPI Status",
                value:
                dashboardVM.upiStatus
            )
        }
    }

    private func statusCard(
        title: String,
        value: String
    ) -> some View {

        HStack {

            Text(title)

            Spacer()

            Text(value)
                .fontWeight(.bold)
                .foregroundColor(
                    value == "Active" || value == "Connected"
                    ? AppColors.successGreen
                    : AppColors.errorRed
                )
        }
        .padding()

        .background(
            AppColors.cardBackground
        )

        .cornerRadius(18)
    }
}

// MARK: LOGOUT BUTTON
extension MerchantHomeView {

    private var logoutButton: some View {

        Button {

            session.logout()

        } label: {

            HStack {

                Image(
                    systemName:
                    "rectangle.portrait.and.arrow.right"
                )

                Text("Logout")
                    .fontWeight(.bold)
            }
            .foregroundColor(.white)

            .frame(maxWidth: .infinity)
            .frame(height: 58)

            .background(
                AppColors.errorRed
            )

            .cornerRadius(18)
        }
    }
}
