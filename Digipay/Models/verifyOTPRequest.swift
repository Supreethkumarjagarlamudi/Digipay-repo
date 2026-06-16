import Foundation

struct VerifyOTPRequest: Codable {

    let phone_number: String
    let otp_code: String
}
