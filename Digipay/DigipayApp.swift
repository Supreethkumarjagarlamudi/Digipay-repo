import SwiftUI

@main
struct DigipayApp: App {

    @StateObject
    private var session =
    SessionManager.shared

    var body: some Scene {

        WindowGroup {

            LaunchView()

                .environmentObject(
                    session
                )

        }
    }
}
