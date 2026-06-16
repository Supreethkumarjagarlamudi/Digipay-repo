import Foundation
import Combine

@MainActor
final class HomeViewModel:
ObservableObject {

    @Published var merchants:
    [NearbyMerchant] = []

    @Published var isLoading = false

    @Published var errorMessage = ""

    func loadRecommendations(

        latitude: Double,

        longitude: Double,

        heading: Double,

        speed: Double

    ) async {

        isLoading = true

        errorMessage = ""

        do {

            merchants =
            try await MerchantService
                .shared
                .fetchRecommendations(

                    latitude: latitude,

                    longitude: longitude,

                    heading: heading,

                    speed: speed
                )

        } catch {

            errorMessage =
            error.localizedDescription

            print(error)
        }

        isLoading = false
    }
}
