import Foundation

struct ExpenseTransaction: Codable, Identifiable {
    let id: Int
    let merchant_name: String
    let amount: Double
    let category: String
    let timestamp: String
    let latitude: Double?
    let longitude: Double?
    let heading: Double?
    let speed: Double?
}

struct CategoryInsight: Codable, Identifiable {
    var id: String { category }
    let category: String
    let amount: Double
    let percentage: Double
    let icon: String
}

struct WalletAnalyticsPayload: Codable {
    let balance: Double
    let spent_this_month: Double
    let spent_this_week: Double
    let saved_this_month: Double
    let budget_limit: Double
    let budget_progress: Double
    let category_breakdown: [CategoryInsight]
    let recent_transactions: [ExpenseTransaction]
    let savings_suggestions: [String]
    let peak_spending_time: String
    let location_spending_summary: String
}
