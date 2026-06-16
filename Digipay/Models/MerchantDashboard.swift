import Foundation

struct MerchantPayment: Codable, Identifiable {
    let id: Int
    let amount: Double
    let timestamp: String
    let customer_phone: String
}

struct MerchantDashboardResponse: Codable {
    let business_name: String
    let owner_name: String
    let category: String
    let digipin: String
    let today_revenue: Double
    let today_customers: Int
    let total_payments_count: Int
    let nearby_activity_count: Int
    let recent_payments: [MerchantPayment]
    let upi_status: String
    let digipin_status: String
}
