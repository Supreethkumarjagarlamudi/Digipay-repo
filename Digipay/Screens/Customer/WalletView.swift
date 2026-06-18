import SwiftUI

struct WalletView: View {
    @StateObject private var walletVM = WalletViewModel()
    @EnvironmentObject private var session: SessionManager
    @State private var showAddExpenseSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.primaryBackground
                    .ignoresSafeArea()

                if walletVM.isLoading && walletVM.recentTransactions.isEmpty {
                    VStack {
                        Spacer()
                        ProgressView("Loading analytics...")
                            .tint(AppColors.primaryBlue)
                        Spacer()
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 28) {
                            headerSection
                            
                            // 1. Core Financial Overview
                            financialOverviewGrid
                            
                            // 2. Budget Progress Gauge
                            budgetSection
                            
                            // 3. Custom Category Pie Chart
                            VStack(alignment: .leading, spacing: 14) {
                                Text("Expense Breakdown")
                                    .font(.title3.bold())
                                    .foregroundColor(AppColors.primaryText)
                                
                                PieChartView(breakdown: walletVM.categoryBreakdown)
                            }
                            
                            // 4. Categories breakdown detail cards
                            categoryBreakdownSection
                            
                            // 5. Context Intelligence
                            contextIntelligenceSection
                            
                            // 6. AI Suggestions / Insights
                            suggestionsSection
                            
                            // 7. Recent Transactions
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
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("WalletTransactionCreated"))) { _ in
                Task {
                    await walletVM.loadAnalytics()
                }
            }
            .sheet(isPresented: $showAddExpenseSheet) {
                AddExpenseView(walletVM: walletVM)
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
                    .foregroundColor(AppColors.primaryText)
                Text("Real-time telemetry-backed expenses")
                    .font(.subheadline)
                    .foregroundColor(AppColors.secondaryText)
            }
            Spacer()
            
            Button {
                showAddExpenseSheet = true
            } label: {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(AppColors.primaryBlue)
                    .font(.title2)
            }
            .accessibilityIdentifier("addExpenseBtn")
            .padding(.trailing, 8)
            
            Circle()
                .fill(AppColors.primaryBlue.opacity(0.12))
                .frame(width: 44, height: 44)
                .overlay {
                    Image(systemName: "sparkles")
                        .foregroundColor(AppColors.primaryBlue)
                        .font(.title3)
                }
        }
    }
}

// MARK: - FINANCIAL OVERVIEW GRID
extension WalletView {
    private var financialOverviewGrid: some View {
        VStack(spacing: 14) {
            // Balance Card (Main Hero)
            VStack(alignment: .leading, spacing: 12) {
                Text("Estimated Balance")
                    .foregroundColor(.white.opacity(0.8))
                    .font(.subheadline)
                
                Text("₹\(walletVM.balance, specifier: "%.2f")")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                
                HStack {
                    Label("\(walletVM.recentTransactions.count) Payments This Cycle", systemImage: "arrow.left.arrow.right")
                    Spacer()
                    Text("Auto-tracked")
                        .font(.caption2.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.white.opacity(0.2))
                        .cornerRadius(6)
                }
                .font(.caption)
                .foregroundColor(.white.opacity(0.9))
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    colors: [AppColors.primaryBlue, AppColors.secondaryCyan],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(28)
            .shadow(color: AppColors.primaryBlue.opacity(0.25), radius: 10, y: 5)
            
            // 3-Way Grid for Income, Budget, Remaining
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                overviewMiniCard(
                    title: "Monthly Income",
                    value: "₹\(Int(session.monthlyIncome))",
                    icon: "arrow.down.forward.circle.fill",
                    color: AppColors.successGreen
                )
                
                overviewMiniCard(
                    title: "Monthly Budget",
                    value: "₹\(Int(session.monthlyBudget))",
                    icon: "slider.horizontal.3",
                    color: AppColors.primaryBlue
                )
                
                overviewMiniCard(
                    title: "Total Spent",
                    value: "₹\(Int(walletVM.spentThisMonth))",
                    icon: "arrow.up.forward.circle.fill",
                    color: AppColors.warningOrange
                )
                
                let remainingBudget = session.monthlyBudget - walletVM.spentThisMonth
                overviewMiniCard(
                    title: "Remaining Budget",
                    value: "₹\(Int(remainingBudget))",
                    icon: "checkmark.shield.fill",
                    color: remainingBudget <= 0 ? AppColors.errorRed : AppColors.secondaryCyan
                )
            }
        }
    }
    
    private func overviewMiniCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundColor(color)
                Spacer()
            }
            
            Text(value)
                .font(.title3.bold())
                .foregroundColor(AppColors.primaryText)
                .accessibilityIdentifier(title == "Total Spent" ? "totalSpentText" : (title == "Monthly Budget" ? "profileBudgetInput" : ""))
            
            Text(title)
                .font(.caption2)
                .foregroundColor(AppColors.secondaryText)
                .lineLimit(1)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(18)
    }
}

// MARK: - BUDGET PROGRESS
extension WalletView {
    private var budgetSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Budget Usage")
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.primaryText)
                Spacer()
                Text("₹\(walletVM.spentThisMonth, specifier: "%.0f") spent of ₹\(walletVM.budgetLimit, specifier: "%.0f") limit")
                    .font(.caption)
                    .foregroundColor(AppColors.secondaryText)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(AppColors.borderColor.opacity(0.2))
                        .frame(height: 10)
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(walletVM.budgetProgress > 0.9 ? AppColors.errorRed : (walletVM.budgetProgress > 0.7 ? AppColors.warningOrange : AppColors.primaryBlue))
                        .frame(width: min(geometry.size.width, geometry.size.width * CGFloat(walletVM.budgetProgress)), height: 10)
                }
            }
            .frame(height: 10)
            .accessibilityIdentifier("budgetProgressBar")
            
            HStack {
                Text(walletVM.budgetProgress > 0.9 ? "Warning: Critical limit reached!" : (walletVM.budgetProgress > 0.7 ? "Approaching limit threshold" : "Budget status healthy"))
                    .font(.caption2)
                    .foregroundColor(walletVM.budgetProgress > 0.9 ? AppColors.errorRed : (walletVM.budgetProgress > 0.7 ? AppColors.warningOrange : AppColors.secondaryText))
                Spacer()
                Text("\(Int(min(1.0, walletVM.budgetProgress) * 100))%")
                    .font(.caption.bold())
                    .foregroundColor(AppColors.primaryText)
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
            Text("Category Progress Details")
                .font(.headline)
                .foregroundColor(AppColors.primaryText)
            
            if walletVM.categoryBreakdown.isEmpty || walletVM.categoryBreakdown.allSatisfy({ $0.amount == 0 }) {
                Text("No categorized expenses recorded yet.")
                    .font(.subheadline)
                    .foregroundColor(AppColors.secondaryText)
                    .padding(.vertical, 10)
            } else {
                ForEach(walletVM.categoryBreakdown) { insight in
                    if insight.amount > 0 {
                        VStack(spacing: 8) {
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(AppColors.primaryBlue.opacity(0.12))
                                    .frame(width: 36, height: 36)
                                    .overlay {
                                        Image(systemName: insight.icon)
                                            .foregroundColor(AppColors.primaryBlue)
                                            .font(.caption)
                                    }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(insight.category)
                                        .font(.subheadline.bold())
                                        .foregroundColor(AppColors.primaryText)
                                    Text(String(format: "%.0f%% of total spent", insight.percentage))
                                        .font(.caption2)
                                        .foregroundColor(AppColors.secondaryText)
                                }
                                Spacer()
                                Text("₹\(insight.amount, specifier: "%.0f")")
                                    .font(.subheadline.bold())
                                    .foregroundColor(AppColors.primaryText)
                            }
                            
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(AppColors.borderColor.opacity(0.2))
                                    .frame(height: 5)
                                
                                GeometryReader { geometry in
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(AppColors.secondaryCyan)
                                        .frame(width: min(geometry.size.width, geometry.size.width * CGFloat(insight.percentage / 100.0)), height: 5)
                                }
                                .frame(height: 5)
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
            Text("Context Intelligence Insights")
                .font(.title3.bold())
                .foregroundColor(AppColors.primaryText)
            
            VStack(spacing: 14) {
                HStack {
                    Label("Peak Spending Hour", systemImage: "clock.fill")
                        .foregroundColor(AppColors.primaryText)
                        .font(.subheadline)
                    Spacer()
                    Text(walletVM.peakSpendingTime.isEmpty ? "Analyzing habits..." : walletVM.peakSpendingTime)
                        .font(.caption.bold())
                        .foregroundColor(AppColors.primaryBlue)
                }
                
                Divider()
                    .background(AppColors.borderColor.opacity(0.3))
                
                HStack(alignment: .top) {
                    Label("Location Insights", systemImage: "mappin.and.ellipse")
                        .foregroundColor(AppColors.primaryText)
                        .font(.subheadline)
                    Spacer()
                    Text(walletVM.locationSpendingSummary.isEmpty ? "No telemetry data recorded" : walletVM.locationSpendingSummary)
                        .font(.caption.bold())
                        .foregroundColor(AppColors.secondaryCyan)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: 180)
                }
                
            }
            .padding()
            .background(AppColors.primaryBackground.opacity(0.4))
            .cornerRadius(16)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(22)
    }
}

// MARK: - SMART AI SUGGESTIONS
extension WalletView {
    private var suggestionsSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(AppColors.primaryBlue)
                Text("AI Expense Intelligence")
                    .font(.title3.bold())
                    .foregroundColor(AppColors.primaryText)
            }
            
            if walletVM.aiInsights.isEmpty {
                Text("Collecting transaction telemetry to generate recommendations...")
                    .font(.subheadline)
                    .foregroundColor(AppColors.secondaryText)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppColors.cardBackground)
                    .cornerRadius(18)
            } else {
                ForEach(walletVM.aiInsights) { insight in
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(alignment: .top, spacing: 14) {
                            Circle()
                                .fill(getInsightColor(insight.type).opacity(0.12))
                                .frame(width: 40, height: 40)
                                .overlay {
                                    Image(systemName: insight.icon)
                                        .foregroundColor(getInsightColor(insight.type))
                                        .font(.subheadline.bold())
                                }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(insight.title)
                                    .font(.subheadline.bold())
                                    .foregroundColor(AppColors.primaryText)
                                
                                Text(insight.message)
                                    .font(.footnote)
                                    .foregroundColor(AppColors.secondaryText)
                                    .lineSpacing(4)
                            }
                        }
                        
                        HStack(spacing: 8) {
                            // Priority badge
                            Text("\(insight.priority.capitalized) Priority")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(getPriorityColor(insight.priority))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(getPriorityColor(insight.priority).opacity(0.12))
                                .cornerRadius(6)
                            
                            // Confidence badge
                            Text("\(insight.confidence)% Confidence")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(AppColors.successGreen)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(AppColors.successGreen.opacity(0.12))
                                .cornerRadius(6)
                        }
                        .padding(.leading, 54)
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(18)
                    .shadow(color: Color.black.opacity(0.02), radius: 5, y: 3)
                }
            }
        }
    }
    
    private func getInsightColor(_ type: String) -> Color {
        switch type {
        case "spending_pattern": return AppColors.primaryBlue
        case "context_intelligence": return AppColors.secondaryCyan
        case "budget_coach": return AppColors.warningOrange
        default: return AppColors.primaryBlue
        }
    }
    
    private func getPriorityColor(_ priority: String) -> Color {
        switch priority.lowercased() {
        case "high": return AppColors.errorRed
        case "medium": return AppColors.warningOrange
        case "low": return AppColors.secondaryCyan
        default: return AppColors.secondaryText
        }
    }
}

// MARK: - TRANSACTIONS LIST
extension WalletView {
    private var transactionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Transactions")
                .font(.title3.bold())
                .foregroundColor(AppColors.primaryText)
            
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
                                .foregroundColor(AppColors.primaryText)
                            
                            HStack(spacing: 8) {
                                Text(formatTimestamp(tx.timestamp))
                                    .font(.caption)
                                    .foregroundColor(AppColors.secondaryText)
                                
                                if tx.latitude != nil {
                                    Text("• Telemetry Verified")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundColor(AppColors.successGreen)
                                        .padding(.horizontal, 5)
                                        .padding(.vertical, 2)
                                        .background(AppColors.successGreen.opacity(0.12))
                                        .cornerRadius(4)
                                }
                            }
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
        .accessibilityIdentifier("transactionList")
    }

    private func getCategoryIcon(_ cat: String) -> String {
        switch cat.lowercased() {
        case "food", "cafe", "restaurant": return "cup.and.saucer.fill"
        case "shopping", "retail": return "cart.fill"
        case "medical": return "cross.case.fill"
        case "transport": return "car.fill"
        case "bills": return "doc.text.fill"
        case "entertainment": return "play.tv.fill"
        case "education": return "book.fill"
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

// MARK: - CUSTOM PIE CHART & SHAPES
struct PieChartView: View {
    let breakdown: [CategoryInsight]

    private var cleanBreakdown: [CategoryInsight] {
        breakdown.filter { $0.amount > 0 }
    }

    private var totalSpent: Double {
        cleanBreakdown.reduce(0.0) { $0 + $1.amount }
    }

    private let colors: [Color] = [
        AppColors.primaryBlue,
        AppColors.secondaryCyan,
        AppColors.successGreen,
        AppColors.warningOrange,
        AppColors.errorRed,
        Color.purple,
        Color.pink
    ]

    var body: some View {
        if cleanBreakdown.isEmpty {
            VStack {
                Circle()
                    .stroke(AppColors.borderColor.opacity(0.2), lineWidth: 16)
                    .frame(width: 140, height: 140)
                    .overlay {
                        Text("No data")
                            .font(.subheadline)
                            .foregroundColor(AppColors.secondaryText)
                    }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .center)
            .background(AppColors.cardBackground)
            .cornerRadius(22)
        } else {
            HStack(spacing: 24) {
                // Circular slices
                ZStack {
                    ForEach(0..<cleanBreakdown.count, id: \.self) { index in
                        let cumulativePercentage = cleanBreakdown[0..<index].reduce(0.0) { $0 + ($1.amount / totalSpent) }
                        let percentage = cleanBreakdown[index].amount / totalSpent
                        
                        let startAngle = Angle(degrees: -90.0 + (cumulativePercentage * 360.0))
                        let endAngle = Angle(degrees: -90.0 + ((cumulativePercentage + percentage) * 360.0))
                        
                        PieSliceShape(startAngle: startAngle, endAngle: endAngle)
                            .stroke(colors[index % colors.count], style: StrokeStyle(lineWidth: 18, lineCap: .round))
                            .frame(width: 110, height: 110)
                    }
                    
                    VStack(spacing: 2) {
                        Text("Spent")
                            .font(.caption2)
                            .foregroundColor(AppColors.secondaryText)
                        Text("₹\(Int(totalSpent))")
                            .font(.subheadline.bold())
                            .foregroundColor(AppColors.primaryText)
                    }
                }
                .frame(width: 120, height: 120)
                
                // Legend
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(0..<cleanBreakdown.count, id: \.self) { index in
                        let item = cleanBreakdown[index]
                        HStack(spacing: 8) {
                            Circle()
                                .fill(colors[index % colors.count])
                                .frame(width: 8, height: 8)
                            Text(item.category)
                                .font(.caption)
                                .foregroundColor(AppColors.primaryText)
                                .lineLimit(1)
                            Spacer()
                            Text(String(format: "%.0f%%", (item.amount / totalSpent) * 100))
                                .font(.caption.bold())
                                .foregroundColor(AppColors.secondaryText)
                        }
                    }
                }
            }
            .padding(20)
            .background(AppColors.cardBackground)
            .cornerRadius(22)
        }
    }
}

struct PieSliceShape: Shape {
    let startAngle: Angle
    let endAngle: Angle

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        return path
    }
}

struct AddExpenseView: View {
    @ObservedObject var walletVM: WalletViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var amount = ""
    @State private var selectedCategory = "Cafe"
    @State private var isSaving = false
    @State private var errorMessage = ""
    
    let categories = ["Cafe", "Food", "Shopping", "Medical", "Transport", "Bills", "Entertainment", "Education"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.primaryBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Expense Title")
                            .fontWeight(.semibold)
                        TextField("Enter title (e.g., Coffee)", text: $title)
                            .accessibilityIdentifier("expenseTitleField")
                            .padding()
                            .background(AppColors.cardBackground)
                            .cornerRadius(12)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Amount (₹)")
                            .fontWeight(.semibold)
                        TextField("0.00", text: $amount)
                            .accessibilityIdentifier("expenseAmountField")
                            .keyboardType(.decimalPad)
                            .padding()
                            .background(AppColors.cardBackground)
                            .cornerRadius(12)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Category")
                            .fontWeight(.semibold)
                        
                        Menu {
                            ForEach(categories, id: \.self) { cat in
                                Button(cat) {
                                    selectedCategory = cat
                                }
                                .accessibilityIdentifier("categoryOption_\(cat)")
                            }
                        } label: {
                            HStack {
                                Text(selectedCategory)
                                    .foregroundColor(AppColors.primaryText)
                                Spacer()
                                Image(systemName: "chevron.down")
                            }
                            .padding()
                            .background(AppColors.cardBackground)
                            .cornerRadius(12)
                        }
                        .accessibilityIdentifier("expenseCategoryPicker")
                    }
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    Button(action: saveExpense) {
                        HStack {
                            if isSaving {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Save Expense")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(title.isEmpty || amount.isEmpty ? Color.gray.opacity(0.4) : AppColors.primaryBlue)
                        .cornerRadius(14)
                    }
                    .disabled(title.isEmpty || amount.isEmpty || isSaving)
                    .accessibilityIdentifier("saveExpenseBtn")
                    
                    Spacer()
                }
                .padding(24)
            }
            .navigationTitle("Add Custom Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveExpense() {
        guard let amt = Double(amount), amt > 0 else {
            errorMessage = "Please enter a valid amount"
            return
        }
        isSaving = true
        Task {
            do {
                _ = try await WalletService.shared.createTransaction(
                    merchantName: title,
                    amount: amt,
                    category: selectedCategory,
                    latitude: nil,
                    longitude: nil,
                    heading: nil,
                    speed: nil
                )
                NotificationCenter.default.post(name: NSNotification.Name("WalletTransactionCreated"), object: nil)
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
            }
            isSaving = false
        }
    }
}
