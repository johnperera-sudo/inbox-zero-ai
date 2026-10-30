import Foundation
import RevenueCat

@MainActor
class PaywallManager: ObservableObject {
    @Published var isPro = false
    @Published var offerings: Offerings?
    @Published var actionCount: Int = 0
    
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
    
    func increment() {
        actionCount += 1
    }
    
    func shouldShowPaywall() -> Bool {
        return !isPro && actionCount >= FREE_LIMIT
    }
    
    func restorePurchases() async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            Purchases.shared.restorePurchases { customerInfo, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                let isActive = customerInfo?.entitlements[self.entitlement]?.isActive == true
                DispatchQueue.main.async {
                    self.isPro = isActive
                }
                continuation.resume(returning: isActive)
            }
        }
    }
    
    func purchase(package: Package) async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            Purchases.shared.purchase(package: package) { transaction, customerInfo, error, userCancelled in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                if userCancelled {
                    continuation.resume(returning: false)
                    return
                }
                let isActive = customerInfo?.entitlements[self.entitlement]?.isActive == true
                DispatchQueue.main.async {
                    self.isPro = isActive
                }
                continuation.resume(returning: isActive)
            }
        }
    }
    
    func purchase() async throws -> Bool {
        guard let package = offerings?.current?.availablePackages.first else {
            throw NSError(domain: "Purchase", code: 2, userInfo: [NSLocalizedDescriptionKey: "No packages available"])
        }
        return try await purchase(package: package)
    }
}
