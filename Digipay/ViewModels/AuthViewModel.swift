import Foundation
import Combine

@MainActor
final class AuthViewModel: ObservableObject {

    @Published var isLoading = false
    @Published var errorMessage = ""

    @Published var otp = ""

    @Published var isAuthenticated = false

    @Published var accessToken = ""

    func sendOTP(
        phoneNumber: String
    ) async {

        isLoading = true

        errorMessage = ""

        do {

            let response = try await AuthService
                .shared
                .sendOTP(
                    phoneNumber: phoneNumber
                )

            otp = response.otp

        } catch {

            errorMessage =
            error.localizedDescription
        }

        isLoading = false
    }

    func verifyOTP(

        phoneNumber: String,

        otpCode: String

    ) async {

        isLoading = true

        errorMessage = ""

        do {

            let response = try await AuthService

                .shared

                .verifyOTP(

                    phoneNumber: phoneNumber,

                    otpCode: otpCode

                )

            accessToken =
            response.access_token

            UserDefaults.standard.set(
                response.access_token,
                forKey: "accessToken"
            )
            UserDefaults.standard.set(
                response.profile_completed,
                forKey: "profileCompleted"
            )
            UserDefaults.standard.set(
                response.user.full_name ?? "",
                forKey: "fullName"
            )
            UserDefaults.standard.set(
                response.user.phone_number,
                forKey: "phoneNumber"
            )
            if let budget = response.user.monthly_budget {
                UserDefaults.standard.set(budget, forKey: "monthlyBudget")
            }
            if let income = response.user.monthly_income {
                UserDefaults.standard.set(income, forKey: "monthlyIncome")
            }
            isAuthenticated = true
        } catch let error as NSError {
            
            errorMessage = error.localizedDescription

        }
        catch {

            errorMessage =
            "Something went wrong"

        }
        isLoading = false

    }

}
