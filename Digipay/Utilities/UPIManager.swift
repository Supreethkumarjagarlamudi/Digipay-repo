import UIKit

@MainActor
final class UPIManager {

    static let shared = UPIManager()

    private init() {}

    func openUPILink(
        deepLink: String,
        preferredApp: String = "Ask Every Time"
    ) {
        var targetLink = deepLink
        let cleanedPreferredApp = preferredApp.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        if cleanedPreferredApp != "ask every time" && deepLink.hasPrefix("upi://") {
            let parameters = String(deepLink.dropFirst("upi://".count))

            var customSchemesToTry: [String] = []
            switch cleanedPreferredApp {
            case "google pay", "gpay":
                customSchemesToTry = ["tez://\(parameters)", "gpay://\(parameters)"]
            case "phonepe":
                customSchemesToTry = ["phonepe://\(parameters)"]
            case "paytm":
                customSchemesToTry = ["paytmmp://\(parameters)", "paytm://\(parameters)"]
            case "bhim":
                customSchemesToTry = ["bhim://\(parameters)"]
            default:
                break
            }

            for scheme in customSchemesToTry {
                if let url = URL(string: scheme), UIApplication.shared.canOpenURL(url) {
                    targetLink = scheme
                    break
                }
            }
        }

        guard let url = URL(
            string: targetLink
        ) else {
            print("Invalid UPI URL: \(targetLink)")
            return
        }

        UIApplication.shared.open(
            url,
            options: [:]
        ) { success in
            print(
                "UPI Open Success (\(targetLink)):",
                success
            )
        }
    }
}
