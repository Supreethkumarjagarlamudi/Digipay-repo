import Foundation
import Combine

@MainActor
final class MerchantHomeViewModel: ObservableObject {
    @Published var businessName = ""
    @Published var category = ""
    @Published var digipin = ""
    @Published var todayRevenue: Double = 0.0
    @Published var todayCustomers = 0
    @Published var totalPaymentsCount = 0
    @Published var nearbyActivityCount = 0
    @Published var upiStatus = "Connected"
    @Published var digipinStatus = "Active"
    @Published var recentPayments: [MerchantPayment] = []

    @Published var isLoading = false
    @Published var errorMessage = ""

    func loadDashboard() async {
        isLoading = true
        errorMessage = ""
        do {
            let res = try await MerchantService.shared.fetchDashboard()
            self.businessName = res.business_name
            self.category = res.category
            self.digipin = res.digipin
            self.todayRevenue = res.today_revenue
            self.todayCustomers = res.today_customers
            self.totalPaymentsCount = res.total_payments_count
            self.nearbyActivityCount = res.nearby_activity_count
            self.upiStatus = res.upi_status
            self.digipinStatus = res.digipin_status
            self.recentPayments = res.recent_payments
        } catch {
            self.errorMessage = error.localizedDescription
            print("Error loading merchant dashboard:", error)
        }
        isLoading = false
    }
}
