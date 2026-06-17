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
    @Published var allPayments: [MerchantPayment] = []

    @Published var ownerName = ""
    @Published var gstNumber = ""
    @Published var descriptionText = ""
    @Published var latitude = 0.0
    @Published var longitude = 0.0
    @Published var upiDeepLink = ""
    @Published var dailyRevenueHistory: [DailyRevenueItem] = []

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
            
            self.ownerName = res.owner_name
            self.gstNumber = res.gst_number ?? ""
            self.descriptionText = res.description ?? ""
            self.latitude = res.latitude
            self.longitude = res.longitude
            self.upiDeepLink = res.upi_deep_link
            self.dailyRevenueHistory = res.daily_revenue_history
        } catch {
            self.errorMessage = error.localizedDescription
            print("Error loading merchant dashboard:", error)
        }
        isLoading = false
    }

    func updateMerchantDetails(
        businessName: String,
        ownerName: String,
        category: String,
        gstNumber: String?,
        descriptionText: String?,
        latitude: Double,
        longitude: Double,
        upiDeepLink: String
    ) async throws {
        isLoading = true
        errorMessage = ""
        do {
            let req = MerchantUpdateRequest(
                business_name: businessName,
                owner_name: ownerName,
                category: category,
                gst_number: gstNumber,
                description: descriptionText,
                latitude: latitude,
                longitude: longitude,
                upi_deep_link: upiDeepLink
            )
            let _ = try await MerchantService.shared.updateMerchant(request: req)
            await loadDashboard()
        } catch {
            self.errorMessage = error.localizedDescription
            isLoading = false
            throw error
        }
        isLoading = false
    }

    func loadAllPayments() async {
        isLoading = true
        errorMessage = ""
        do {
            self.allPayments = try await MerchantService.shared.fetchAllPayments()
        } catch {
            self.errorMessage = error.localizedDescription
            print("Error loading all payments statement:", error)
        }
        isLoading = false
    }
}
