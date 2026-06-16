import Foundation

struct MerchantRegistrationData {

    // Step 1

    var businessName: String

    var ownerName: String

    var category: String

    var gstNumber: String

    var description: String

    // Step 2

    var latitude: Double = 0

    var longitude: Double = 0

    var altitude: Double = 0

    var accuracy: Double = 0

    var heading: Double = 0

    var speed: Double = 0
}
