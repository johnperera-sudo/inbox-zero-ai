import Foundation
import SwiftUI
import RevenueCat

@MainActor
class PaywallManager: ObservableObject {
    @Published var isPro: Bool = false
    @Published var actionCount: Int = UserDefaults.standard.integer(forKey: "iz_action_count")
    @Published var offerings: Offerings?

    let FREE_LIMIT = 50
    let entitlement = "pro"

    func checkPro() {
        Task {
            do {
                let info = try await Purchases.shared.customerInfo()
                self.isPro = info.entitlements[entitlement]?.isActive == true
                if let result = try? await Purchases.shared.getOfferings() {
                    self.offerings = result
                }
            } catch {
                print("PaywallManager: Failed to check pro status — \(error.localizedDescription)")
            }
        }
    }

    func increment() {
        guard !isPro else { return }
        actionCount += 1
        UserDefaults.standard.set(actionCount, forKey: "iz_action_count")
    }

    func shouldShowPaywall() -> Bool {
        !isPro && actionCount >= FREE_LIMIT
    }

    func purchase(package: Package) async throws -> Bool {
        let result = try await Purchases.shared.purchase(package: package)
        let isActive = result.customerInfo.entitlements[entitlement]?.isActive == true
        if isActive {
            self.isPro = true
            Haptics.success()
        }
        return isActive
    }

    func restorePurchases() async throws -> Bool {
        let info = try await Purchases.shared.restorePurchases()
        let isActive = info.entitlements[entitlement]?.isActive == true
        if isActive {
            self.isPro = true
            Haptics.success()
        }
        return isActive
    }
}
