import Foundation

final class AuthService {

    static let shared = AuthService()

    private init() {}

    // MARK: SEND OTP

    func sendOTP(
        phoneNumber: String
    ) async throws -> SendOTPResponse {

        guard let url = URL(
            string: Endpoints.sendOTP
        ) else {

            throw URLError(.badURL)

        }

        var request = URLRequest(url: url)

        request.httpMethod = "POST"

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )

        let body = SendOTPRequest(
            phone_number: phoneNumber
        )

        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {

            throw URLError(.badServerResponse)

        }

        if !(200...299).contains(httpResponse.statusCode) {
            print("SEND OTP STATUS:", httpResponse.statusCode)
            if let responseString = String(data: data, encoding: .utf8) {
                print("SEND OTP RESPONSE:", responseString)
            }
            throw parseServerError(
                data: data,
                statusCode: httpResponse.statusCode
            )

        }

        return try JSONDecoder().decode(
            SendOTPResponse.self,
            from: data
        )
    }

    // MARK: VERIFY OTP

    func verifyOTP(
        phoneNumber: String,
        otpCode: String
    ) async throws -> VerifyOTPResponse {

        guard let url = URL(
            string: Endpoints.verifyOTP
        ) else {

            throw URLError(.badURL)

        }

        var request = URLRequest(url: url)

        request.httpMethod = "POST"

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )

        let body = VerifyOTPRequest(

            phone_number: phoneNumber,

            otp_code: otpCode

        )

        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {

            throw URLError(.badServerResponse)

        }

        print("STATUS:", httpResponse.statusCode)

        print(
            String(
                data: data,
                encoding: .utf8
            ) ?? ""
        )

        if !(200...299).contains(httpResponse.statusCode) {

            throw parseServerError(

                data: data,

                statusCode: httpResponse.statusCode

            )

        }

        return try JSONDecoder().decode(

            VerifyOTPResponse.self,

            from: data

        )

    }

}

// MARK: SERVER ERROR

private extension AuthService {

    func parseServerError(

        data: Data,

        statusCode: Int

    ) -> Error {

        if let json = try? JSONSerialization.jsonObject(
            with: data
        ) as? [String: Any] {

            if let detail = json["detail"] as? String {

                return NSError(

                    domain: "",

                    code: statusCode,

                    userInfo: [

                        NSLocalizedDescriptionKey: detail

                    ]

                )

            }

            if let message = json["message"] as? String {

                return NSError(

                    domain: "",

                    code: statusCode,

                    userInfo: [

                        NSLocalizedDescriptionKey: message

                    ]

                )

            }

        }

        return NSError(

            domain: "",

            code: statusCode,

            userInfo: [

                NSLocalizedDescriptionKey:

                "Something went wrong. Please try again."

            ]

        )

    }

}
