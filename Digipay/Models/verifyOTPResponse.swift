import Foundation

struct VerifyOTPResponse: Codable {

    let message: String
    let access_token: String
    let token_type: String
    let user: User
    let role: String
    let profile_completed: Bool
}
