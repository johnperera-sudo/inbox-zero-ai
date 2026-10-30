import SwiftUI
import RevenueCat
@main
struct InboxZeroAIApp: App {
    @StateObject private var store = MailboxStore()
    @StateObject private var paywall = PaywallManager()

    init() {
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "test_sLGfBttwZoOkIyFHy")
    }

    var body: some Scene {
        WindowGroup {
            MainView(store: store, paywall: paywall)
        }
    }
}
