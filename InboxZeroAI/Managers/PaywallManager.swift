import Foundation
import RevenueCat

@MainActor
class PaywallManager: ObservableObject {
    @Published var isPro = false
    @Published var offerings: Offerings?
    
    let FREE_LIMIT = 50
    let entitlement = "pro"
    
    func checkPro() {
        Task {
            do {
                let info = try await Purchases.shared.customerInfo()
                self.isPro = info.entitlements[entitlement]?.isActive == true
                
                Purchases.shared.getOfferings { [weak self] offerings, error in
                    DispatchQueue.main.async {
                        if let offerings = offerings {
                            self?.offerings = offerings
                        }
                    }
                }
                
            } catch {
                print("PaywallManager: Failed to check pro status - \(error.localizedDescription)")
            }
        }
    }
}
