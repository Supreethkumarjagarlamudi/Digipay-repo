// NearbyMerchant.swift

import Foundation

struct NearbyMerchant:
Codable,
Identifiable {
    let id: Int
    let business_name: String
    let category: String
    let distance: Double
    let score: Double
    let upi_deep_link: String
    let ai_reason: String?
    let latitude: Double?
    let longitude: Double?
}
