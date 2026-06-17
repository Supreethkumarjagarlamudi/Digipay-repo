import Foundation

final class MerchantService {

    static let shared = MerchantService()

    private init() {}

    func registerMerchant(
        request: MerchantRegisterRequest
    ) async throws -> MerchantRegisterResponse {

        guard let url = URL(
            string: Endpoints.registerMerchant
        ) else {

            throw URLError(.badURL)
        }

        var urlRequest =
        URLRequest(url: url)

        urlRequest.httpMethod = "POST"

        urlRequest.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )

        if let token =
        UserDefaults.standard.string(
            forKey: "accessToken"
        ) {

            urlRequest.setValue(
                "Bearer \(token)",
                forHTTPHeaderField: "Authorization"
            )
        }

        urlRequest.httpBody =
        try JSONEncoder().encode(
            request
        )

        let (data, _) =
        try await URLSession.shared
            .data(for: urlRequest)

        return try JSONDecoder()
            .decode(
                MerchantRegisterResponse.self,
                from: data
            )
    }
//    func fetchNearbyMerchants(
//        latitude: Double,
//        longitude: Double
//    ) async throws -> [NearbyMerchant] {
//
//        guard let url = URL(
//            string:
//            "\(Endpoints.nearbyMerchants)?latitude=\(latitude)&longitude=\(longitude)"
//        ) else {
//
//            throw URLError(.badURL)
//        }
//
//        let (data, _) = try await URLSession
//            .shared
//            .data(from: url)
//
//        return try JSONDecoder()
//            .decode(
//                [NearbyMerchant].self,
//                from: data
//            )
//    }
    func fetchRecommendations(

        latitude: Double,

        longitude: Double,

        heading: Double,

        speed: Double

    ) async throws -> [NearbyMerchant] {

        let urlString =

        "\(Endpoints.recommendations)?latitude=\(latitude)&longitude=\(longitude)&heading=\(heading)&speed=\(speed)"

        guard let url = URL(
            string: urlString
        ) else {

            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession
            .shared
            .data(from: url)

        return try JSONDecoder()
            .decode(
                [NearbyMerchant].self,
                from: data
            )
    }

    func fetchDashboard() async throws -> MerchantDashboardResponse {
        guard let url = URL(string: Endpoints.merchantDashboard) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        if let token = UserDefaults.standard.string(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        if !(200...299).contains(httpResponse.statusCode) {
            throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to load dashboard metrics"])
        }

        return try JSONDecoder().decode(MerchantDashboardResponse.self, from: data)
    }

    func updateMerchant(
        request: MerchantUpdateRequest
    ) async throws -> MerchantUpdateResponse {
        guard let url = URL(string: Endpoints.updateMerchant) else {
            throw URLError(.badURL)
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "accessToken") {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        urlRequest.httpBody = try JSONEncoder().encode(request)

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        if !(200...299).contains(httpResponse.statusCode) {
            throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to update merchant details"])
        }

        return try JSONDecoder().decode(MerchantUpdateResponse.self, from: data)
    }

    func fetchAllPayments() async throws -> [MerchantPayment] {
        guard let url = URL(string: Endpoints.merchantPayments) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        if let token = UserDefaults.standard.string(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        if !(200...299).contains(httpResponse.statusCode) {
            throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch statements"])
        }

        return try JSONDecoder().decode([MerchantPayment].self, from: data)
    }
}
