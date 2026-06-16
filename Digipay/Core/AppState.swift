import SwiftUI
import Combine

@MainActor
final class AppState: ObservableObject {

    @AppStorage("hasSeenOnboarding")
    var hasSeenOnboarding = false

    @AppStorage("isLoggedIn")
    var isLoggedIn = false
}
