struct User: Codable {
    let id: Int
    let phone_number: String
    let role: String?
    let full_name: String?
    let email: String?
    let profile_completed: Bool?
}
