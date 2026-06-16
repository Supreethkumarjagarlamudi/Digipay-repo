import Foundation

enum NetworkPermissionManager {

    static func requestLocalNetworkAccess() {

        guard let url = URL(
            string: "\(AppConfig.baseURL)/docs"
        ) else {
            return
        }

        URLSession.shared.dataTask(
            with: url
        ) { _, _, _ in

        }.resume()
    }
}
