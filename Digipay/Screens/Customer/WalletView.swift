import SwiftUI

struct WalletView: View {
    @StateObject private var walletVM = WalletViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.primaryBackground
                    .ignoresSafeArea()

                if walletVM.isLoading && walletVM.recentTransactions.isEmpty {
                    VStack {
                        Spacer()
                        ProgressView("Loading analytics...")
                        Spacer()
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            headerSection
                            
                            balanceCard
                            
                            statsSection
                            
                            budgetSection
                            
                            categoryBreakdownSection
                            
                            contextIntelligenceSection
                            
                            suggestionsSection
                            
                            transactionsSection
                        }
                        .padding()
                        .padding(.bottom, 120)
                    }
                    .refreshable {
                        await walletVM.loadAnalytics()
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                Task {
                    await walletVM.loadAnalytics()
                }
            }
        }
    }
}

// MARK: - HEADER
extension WalletView {
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Wallet Intelligence")
                    .font(.system(size: 32, weight: .bold))
                Text("AI-powered expense analysis")
                    .font(.subheadline)
                    .foregroundColor(AppColors.secondaryText)
            }
            Spacer()
            Image("app_logo")
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 44)
        }
    }
}

// MARK: - BALANCE CARD
extension WalletView {
    private var balanceCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Available Balance")
                .foregroundColor(.white.opacity(0.8))
                .font(.subheadline)

            Text("₹\(walletVM.balance, specifier: "%.2f")")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(.white)

            HStack {
                Label("\(walletVM.recentTransactions.count) Payments", systemImage: "arrow.left.arrow.right")
                Spacer()
                Label("Current Cycle", systemImage: "calendar")
            }
            .font(.caption)
            .foregroundColor(.white.opacity(0.9))
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [AppColors.primaryBlue, AppColors.secondaryCyan],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(28)
        .shadow(color: AppColors.primaryBlue.opacity(0.25), radius: 10, y: 5)
    }
}

// MARK: - STATS
extension WalletView {
    private var statsSection: some View {
        HStack(spacing: 14) {
            statCard(
                title: "Spent (Month)",
                value: String(format: "₹%.0f", walletVM.spentThisMonth),
                icon: "arrow.up.circle.fill",
                color: AppColors.primaryBlue
            )

            statCard(
                title: "Saved (Month)",
                value: String(format: "₹%.0f", walletVM.savedThisMonth),
                icon: "banknote.fill",
                color: AppColors.successGreen
            )
        }
    }

    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)

            Text(value)
                .font(.title3.bold())

            Text(title)
                .font(.caption)
                .foregroundColor(AppColors.secondaryText)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.cardBackground)
        .cornerRadius(20)
    }
}

// MARK: - BUDGET PROGRESS
extension WalletView {
    private var budgetSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Monthly Budget Progress")
                    .fontWeight(.bold)
                Spacer()
                Text("₹\(walletVM.spentThisMonth, specifier: "%.0f") / ₹\(walletVM.budgetLimit, specifier: "%.0f")")
                    .font(.caption)
                    .foregroundColor(AppColors.secondaryText)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(AppColors.borderColor.opacity(0.2))
                        .frame(height: 10)
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(walletVM.budgetProgress > 0.85 ? AppColors.errorRed : AppColors.primaryBlue)
                        .frame(width: min(geometry.size.width, geometry.size.width * CGFloat(walletVM.budgetProgress)), height: 10)
                }
            }
            .frame(height: 10)
            
            HStack {
                Text(walletVM.budgetProgress > 0.85 ? "Warning: Approaching Limit!" : "Budget remains healthy")
                    .font(.caption2)
                    .foregroundColor(walletVM.budgetProgress > 0.85 ? AppColors.errorRed : AppColors.secondaryText)
                Spacer()
                Text("\(Int(walletVM.budgetProgress * 100))%")
                    .font(.caption.bold())
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(20)
    }
}

// MARK: - SPENDING BREAKDOWN
extension WalletView {
    private var categoryBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Spending Breakdown")
                .font(.title3.bold())
            
            if walletVM.categoryBreakdown.allSatisfy({ $0.amount == 0 }) {
                Text("No categorized expenses recorded yet.")
                    .font(.subheadline)
                    .foregroundColor(AppColors.secondaryText)
                    .padding(.vertical, 10)
            } else {
                ForEach(walletVM.categoryBreakdown) { insight in
                    if insight.amount > 0 {
                        HStack(spacing: 12) {
                            Circle()
                                .fill(AppColors.primaryBlue.opacity(0.12))
                                .frame(width: 40, height: 40)
                                .overlay {
                                    Image(systemName: insight.icon)
                                        .foregroundColor(AppColors.primaryBlue)
                                }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(insight.category)
                                        .font(.body.bold())
                                    Spacer()
                                    Text("₹\(insight.amount, specifier: "%.0f")")
                                        .font(.body.bold())
                                }
                                
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(AppColors.borderColor.opacity(0.2))
                                        .frame(height: 6)
                                    
                                    GeometryReader { geometry in
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(AppColors.secondaryCyan)
                                            .frame(width: min(geometry.size.width, geometry.size.width * CGFloat(insight.percentage / 100.0)), height: 6)
                                    }
                                    .frame(height: 6)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(22)
    }
}

// MARK: - CONTEXT INTELLIGENCE
extension WalletView {
    private var contextIntelligenceSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Context Intelligence")
                .font(.title3.bold())
            
            VStack(spacing: 12) {
                HStack {
                    Label("Peak Spending Hour", systemImage: "clock.fill")
                        .foregroundColor(AppColors.primaryText)
                    Spacer()
                    Text(walletVM.peakSpendingTime.isEmpty ? "Analyzing..." : walletVM.peakSpendingTime)
                        .font(.caption.bold())
                        .foregroundColor(AppColors.primaryBlue)
                }
                
                Divider()
                
                HStack {
                    Label("Location Insights", systemImage: "mappin.and.ellipse")
                        .foregroundColor(AppColors.primaryText)
                    Spacer()
                    Text(walletVM.locationSpendingSummary)
                        .font(.caption.bold())
                        .foregroundColor(AppColors.secondaryCyan)
                }
            }
            .padding()
            .background(AppColors.primaryBackground.opacity(0.5))
            .cornerRadius(16)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(22)
    }
}

// MARK: - RECOMMENDATIONS
extension WalletView {
    private var suggestionsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Smart Savings Suggestions")
                .font(.title3.bold())
            
            ForEach(walletVM.savingsSuggestions, id: \.self) { suggestion in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(AppColors.warningOrange)
                        .font(.headline)
                        .padding(.top, 2)
                    
                    Text(suggestion)
                        .font(.subheadline)
                        .foregroundColor(AppColors.secondaryText)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppColors.warningOrange.opacity(0.08))
                .cornerRadius(16)
            }
        }
    }
}

// MARK: - TRANSACTIONS LIST
extension WalletView {
    private var transactionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Transactions")
                .font(.title3.bold())
            
            if walletVM.recentTransactions.isEmpty {
                Text("No transactions logged yet.")
                    .font(.subheadline)
                    .foregroundColor(AppColors.secondaryText)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                ForEach(walletVM.recentTransactions) { tx in
                    HStack {
                        Circle()
                            .fill(AppColors.primaryBlue.opacity(0.12))
                            .frame(width: 44, height: 44)
                            .overlay {
                                Image(systemName: getCategoryIcon(tx.category))
                                    .foregroundColor(AppColors.primaryBlue)
                            }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(tx.merchant_name)
                                .fontWeight(.semibold)
                            Text(formatTimestamp(tx.timestamp))
                                .font(.caption)
                                .foregroundColor(AppColors.secondaryText)
                        }
                        
                        Spacer()
                        
                        Text("-₹\(tx.amount, specifier: "%.2f")")
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.primaryText)
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(18)
                }
            }
        }
    }

    private func getCategoryIcon(_ cat: String) -> String {
        switch cat {
        case "Food": return "cup.and.saucer.fill"
        case "Shopping": return "cart.fill"
        case "Medical": return "cross.case.fill"
        case "Transport": return "car.fill"
        case "Bills": return "doc.text.fill"
        case "Entertainment": return "play.tv.fill"
        case "Education": return "book.fill"
        case "Retail": return "bag.fill"
        default: return "creditcard.fill"
        }
    }

    private func formatTimestamp(_ isoString: String) -> String {
        let inputFormatter = ISO8601DateFormatter()
        inputFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = inputFormatter.date(from: isoString) {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
        
        let fallbackFormatter = DateFormatter()
        fallbackFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let date = fallbackFormatter.date(from: isoString) {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
        
        return "Recent"
    }
}
