import Foundation

final class UserService {
    static let shared = UserService()
    private init() {}

    func updateProfile(
        fullName: String,
        email: String?,
        role: String,
        monthlyBudget: Double? = nil,
        monthlyIncome: Double? = nil
    ) async throws {
        guard let url = URL(string: Endpoints.updateProfile) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        var body: [String: Any] = [
            "full_name": fullName,
            "role": role
        ]
        if let email = email, !email.isEmpty {
            body["email"] = email
        }
        if let budget = monthlyBudget {
            body["monthly_budget"] = budget
        }
        if let income = monthlyIncome {
            body["monthly_income"] = income
        }

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        if !(200...299).contains(httpResponse.statusCode) {
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let detail = json["detail"] as? String {
                throw NSError(
                    domain: "",
                    code: httpResponse.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: detail]
                )
            }
            throw NSError(
                domain: "",
                code: httpResponse.statusCode,
                userInfo: [NSLocalizedDescriptionKey: "Failed to update profile"]
            )
        }
    }

    func fetchProfile() async throws -> User {
        guard let url = URL(string: Endpoints.userProfile) else {
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
            throw NSError(
                domain: "",
                code: httpResponse.statusCode,
                userInfo: [NSLocalizedDescriptionKey: "Failed to fetch profile"]
            )
        }

        let decoder = JSONDecoder()
        return try decoder.decode(User.self, from: data)
    }
}
