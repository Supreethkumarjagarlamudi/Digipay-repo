import Foundation

struct MerchantRegisterRequest:
Codable {

    let business_name: String

    let owner_name: String

    let category: String

    let gst_number: String

    let description: String

    let latitude: Double

    let longitude: Double

    let altitude: Double

    let accuracy: Double

    let heading: Double

    let speed: Double

    let upi_deep_link: String
}
