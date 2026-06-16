import UIKit

final class UPIManager {

    static let shared = UPIManager()

    private init() {}

    func openUPILink(
        deepLink: String
    ) {

        guard let url = URL(
            string: deepLink
        ) else {

            print("Invalid UPI URL")
            return
        }

        UIApplication.shared.open(
            url,
            options: [:]
        ) { success in

            print(
                "UPI Open Success:",
                success
            )
        }
    }
}
