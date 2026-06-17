import Foundation
import SwiftUI
import Combine

@MainActor
final class SessionManager: ObservableObject {

    static let shared = SessionManager()

    @Published var hasSeenOnboarding: Bool
    @Published var isLoggedIn: Bool
    @Published var role: UserRole
    @Published var profileCompleted: Bool
    @Published var accessToken: String
    @Published var fullName: String
    @Published var phoneNumber: String
    @Published var monthlyBudget: Double
    @Published var monthlyIncome: Double
    @Published var defaultUPIApp: String

    private var cancellables = Set<AnyCancellable>()

    private init() {

        hasSeenOnboarding = UserDefaults.standard.bool(
            forKey: "hasSeenOnboarding"
        )

        isLoggedIn = UserDefaults.standard.bool(
            forKey: "isLoggedIn"
        )

        profileCompleted = UserDefaults.standard.bool(
            forKey: "profileCompleted"
        )

        accessToken = UserDefaults.standard.string(
            forKey: "accessToken"
        ) ?? ""

        fullName = UserDefaults.standard.string(
            forKey: "fullName"
        ) ?? ""

        phoneNumber = UserDefaults.standard.string(
            forKey: "phoneNumber"
        ) ?? ""

        let savedBudget = UserDefaults.standard.double(forKey: "monthlyBudget")
        monthlyBudget = savedBudget == 0.0 ? 15000.0 : savedBudget

        let savedIncome = UserDefaults.standard.double(forKey: "monthlyIncome")
        monthlyIncome = savedIncome == 0.0 ? 45000.0 : savedIncome

        defaultUPIApp = UserDefaults.standard.string(
            forKey: "defaultUPIApp"
        ) ?? "Ask Every Time"

        role = UserRole(

            rawValue: UserDefaults.standard.string(
                forKey: "userRole"
            ) ?? UserRole.customer.rawValue

        ) ?? .customer

    }

    func login(

        token: String,

        role: String,

        profileCompleted: Bool,

        fullName: String,
        
        phoneNumber: String = "",
        
        monthlyBudget: Double? = nil,
        
        monthlyIncome: Double? = nil

    ) {

        accessToken = token
        self.profileCompleted = profileCompleted
        self.fullName = fullName
        self.phoneNumber = phoneNumber.isEmpty ? self.phoneNumber : phoneNumber
        
        let budget = monthlyBudget ?? 15000.0
        let income = monthlyIncome ?? 45000.0
        self.monthlyBudget = budget
        self.monthlyIncome = income
        
        isLoggedIn = true

        self.role = UserRole(rawValue: role) ?? .customer

        UserDefaults.standard.set(token, forKey: "accessToken")
        UserDefaults.standard.set(role, forKey: "userRole")
        UserDefaults.standard.set(profileCompleted, forKey: "profileCompleted")
        UserDefaults.standard.set(fullName, forKey: "fullName")
        UserDefaults.standard.set(self.phoneNumber, forKey: "phoneNumber")
        UserDefaults.standard.set(budget, forKey: "monthlyBudget")
        UserDefaults.standard.set(income, forKey: "monthlyIncome")
        UserDefaults.standard.set(true, forKey: "isLoggedIn")

    }

    func logout() {

        accessToken = ""
        fullName = ""
        phoneNumber = ""
        monthlyBudget = 15000.0
        monthlyIncome = 45000.0
        profileCompleted = false
        isLoggedIn = false
        role = .customer

        UserDefaults.standard.removeObject(forKey: "accessToken")
        UserDefaults.standard.removeObject(forKey: "fullName")
        UserDefaults.standard.removeObject(forKey: "phoneNumber")
        UserDefaults.standard.removeObject(forKey: "monthlyBudget")
        UserDefaults.standard.removeObject(forKey: "monthlyIncome")
        UserDefaults.standard.removeObject(forKey: "profileCompleted")
        UserDefaults.standard.removeObject(forKey: "userRole")
        UserDefaults.standard.set(false, forKey: "isLoggedIn")

    }

    func completeRegistration(fullName: String, role: UserRole) {
        self.fullName = fullName
        self.role = role
        self.profileCompleted = true
        self.isLoggedIn = true
        
        UserDefaults.standard.set(fullName, forKey: "fullName")
        UserDefaults.standard.set(role.rawValue, forKey: "userRole")
        UserDefaults.standard.set(true, forKey: "profileCompleted")
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
    }

    func completeOnboarding() {
        self.hasSeenOnboarding = true
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
    }

    func fetchAndSyncProfile() async {
        do {
            let user = try await UserService.shared.fetchProfile()
            self.fullName = user.full_name ?? ""
            self.phoneNumber = user.phone_number
            if let roleStr = user.role, let parsedRole = UserRole(rawValue: roleStr) {
                self.role = parsedRole
                UserDefaults.standard.set(roleStr, forKey: "userRole")
            }
            if let budget = user.monthly_budget, budget > 0 {
                self.monthlyBudget = budget
                UserDefaults.standard.set(budget, forKey: "monthlyBudget")
            }
            if let income = user.monthly_income, income > 0 {
                self.monthlyIncome = income
                UserDefaults.standard.set(income, forKey: "monthlyIncome")
            }
            
            UserDefaults.standard.set(self.fullName, forKey: "fullName")
            UserDefaults.standard.set(self.phoneNumber, forKey: "phoneNumber")
        } catch {
            print("Failed to sync profile from backend:", error)
        }
    }
}
