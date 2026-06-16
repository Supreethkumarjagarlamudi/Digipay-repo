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

        fullName: String

    ) {

        accessToken = token
        self.profileCompleted = profileCompleted
        self.fullName = fullName
        isLoggedIn = true

        self.role = UserRole(rawValue: role) ?? .customer

        UserDefaults.standard.set(token, forKey: "accessToken")
        UserDefaults.standard.set(role, forKey: "userRole")
        UserDefaults.standard.set(profileCompleted, forKey: "profileCompleted")
        UserDefaults.standard.set(fullName, forKey: "fullName")
        UserDefaults.standard.set(true, forKey: "isLoggedIn")

    }

    func logout() {

        accessToken = ""
        fullName = ""
        profileCompleted = false
        isLoggedIn = false
        role = .customer

        UserDefaults.standard.removeObject(forKey: "accessToken")
        UserDefaults.standard.removeObject(forKey: "fullName")
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

}
