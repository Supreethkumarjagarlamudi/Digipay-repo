import Foundation
import Combine

@MainActor
final class WalletViewModel: ObservableObject {
    @Published var balance: Double = 0.0
    @Published var spentThisMonth: Double = 0.0
    @Published var spentThisWeek: Double = 0.0
    @Published var savedThisMonth: Double = 0.0
    @Published var budgetLimit: Double = 15000.0
    @Published var budgetProgress: Double = 0.0
    @Published var categoryBreakdown: [CategoryInsight] = []
    @Published var recentTransactions: [ExpenseTransaction] = []
    @Published var savingsSuggestions: [String] = []
    @Published var peakSpendingTime: String = ""
    @Published var locationSpendingSummary: String = ""

    @Published var isLoading = false
    @Published var errorMessage = ""

    func loadAnalytics() async {
        isLoading = true
        errorMessage = ""
        do {
            let payload = try await WalletService.shared.fetchAnalytics()
            self.balance = payload.balance
            self.spentThisMonth = payload.spent_this_month
            self.spentThisWeek = payload.spent_this_week
            self.savedThisMonth = payload.saved_this_month
            self.budgetLimit = payload.budget_limit
            self.budgetProgress = payload.budget_progress
            self.categoryBreakdown = payload.category_breakdown
            self.recentTransactions = payload.recent_transactions
            self.savingsSuggestions = payload.savings_suggestions
            self.peakSpendingTime = payload.peak_spending_time
            self.locationSpendingSummary = payload.location_spending_summary
        } catch {
            self.errorMessage = error.localizedDescription
            print("Error loading wallet analytics:", error)
        }
        isLoading = false
    }
}
