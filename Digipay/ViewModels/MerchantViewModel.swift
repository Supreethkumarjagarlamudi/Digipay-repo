
import Foundation
import Combine

@MainActor
final class MerchantViewModel: ObservableObject {

    @Published var isLoading = false

    @Published var errorMessage = ""

    @Published var registrationSuccess =
    false

    func registerMerchant(
        request: MerchantRegisterRequest
    ) async {

        isLoading = true

        errorMessage = ""

        do {

            _ = try await MerchantService
                .shared
                .registerMerchant(
                    request: request
                )

            registrationSuccess = true

        } catch {

            errorMessage =
            error.localizedDescription
        }

        isLoading = false
    }
}
