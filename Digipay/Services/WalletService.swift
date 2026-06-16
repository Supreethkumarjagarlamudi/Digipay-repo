import Foundation

final class WalletService {
    static let shared = WalletService()
    private init() {}

    func createTransaction(
        merchantName: String,
        amount: Double,
        category: String,
        latitude: Double?,
        longitude: Double?,
        heading: Double?,
        speed: Double?
    ) async throws -> ExpenseTransaction {
        guard let url = URL(string: Endpoints.createTransaction) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        var body: [String: Any] = [
            "merchant_name": merchantName,
            "amount": amount,
            "category": category
        ]
        if let lat = latitude { body["latitude"] = lat }
        if let lon = longitude { body["longitude"] = lon }
        if let hd = heading { body["heading"] = hd }
        if let sp = speed { body["speed"] = sp }

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        if !(200...299).contains(httpResponse.statusCode) {
            throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to log payment transaction"])
        }

        return try JSONDecoder().decode(ExpenseTransaction.self, from: data)
    }

    func fetchAnalytics() async throws -> WalletAnalyticsPayload {
        guard let url = URL(string: Endpoints.walletAnalytics) else {
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
            throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch wallet analytics"])
        }

        return try JSONDecoder().decode(WalletAnalyticsPayload.self, from: data)
    }
}
