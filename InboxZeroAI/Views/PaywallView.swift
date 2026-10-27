import SwiftUI
import RevenueCat

struct PaywallView: View {
    @ObservedObject var paywall: PaywallManager
    @ObservedObject var store: MailboxStore
    @State private var selectedPackage: Package?
    @State private var isPurchasing = false
    @State private var errorMessage: String?
    @Environment(\.dismiss) private var dismiss

    private var packages: [Package] {
        paywall.offerings?.current?.availablePackages ?? []
    }

    var body: some View {
        ZStack {
            Color.izCanvas.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    handle
                    heroSection
                    planList
                    ctaButton
                    termsText
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .scrollIndicators(.hidden)

            if isPurchasing {
                purchasingOverlay
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            paywall.checkPro()
        }
    }

    private var handle: some View {
        Capsule()
            .fill(Color.izTextSecondary.opacity(0.3))
            .frame(width: 40, height: 5)
            .padding(.top, 8)
    }

    private var heroSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.izAccent.opacity(0.2))
                    .frame(width: 80, height: 80)
                Image(systemName: "crown.fill")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(Color.izAccentLight)
            }

            Text("Unlock Pro")
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(Color.izText)

            Text("You've used \(paywall.actionCount) of \(paywall.FREE_LIMIT) free actions. Go unlimited.")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.izTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 8)
    }

    private var planList: some View {
        VStack(spacing: 12) {
            if packages.isEmpty {
                fallbackPlan(.monthly)
                fallbackPlan(.annual)
            } else {
                ForEach(packages, id: \.identifier) { pkg in
                    planCard(pkg)
                }
            }
        }
    }

    private func planCard(_ pkg: Package) -> some View {
        let isSelected = selectedPackage?.identifier == pkg.identifier
        return Button {
            Haptics.tap()
            selectedPackage = pkg
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(pkg.storeProduct.localizedTitle)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.izText)
                    Text(pkg.storeProduct.localizedPriceString)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.izTextSecondary)
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(isSelected ? Color.izAccentLight : Color.izTextSecondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.izSurface.opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(isSelected ? Color.izAccentLight : Color.izHairline, lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private enum FallbackPlan { case monthly, annual }

    private func fallbackPlan(_ plan: FallbackPlan) -> some View {
        let title = plan == .monthly ? "Monthly" : "Annual"
        let price = plan == .monthly ? "$9.99 / mo" : "$59.99 / yr"
        let subtitle = plan == .annual ? "Save 50%" : nil
        let isSelected = selectedPlanFallback == plan

        return Button {
            Haptics.tap()
            selectedPlanFallback = plan
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color.izText)
                        if let subtitle {
                            Text(subtitle)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(Color.izCanvas)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(Color.izSuccess))
                        }
                    }
                    Text(price)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.izTextSecondary)
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(isSelected ? Color.izAccentLight : Color.izTextSecondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.izSurface.opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(isSelected ? Color.izAccentLight : Color.izHairline, lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    @State private var selectedPlanFallback: FallbackPlan?

    private var ctaButton: some View {
        Button {
            purchase()
        } label: {
            Text("Continue")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Color.izCanvas)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.izAccent)
                        .shadow(color: Color.izAccent.opacity(0.3), radius: 12, y: 4)
                )
        }
        .buttonStyle(.plain)
        .disabled(selectedPackage == nil && selectedPlanFallback == nil)
        .opacity(selectedPackage == nil && selectedPlanFallback == nil ? 0.5 : 1)
    }

    private var termsText: some View {
        VStack(spacing: 4) {
            Text("Cancel anytime. Payment charged to your Apple ID.")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color.izTextSecondary)

            Button {
                dismiss()
            } label: {
                Text("Maybe Later")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.izTextSecondary)
            }
            .buttonStyle(.plain)
            .padding(.top, 8)
        }
    }

    private var purchasingOverlay: some View {
        ZStack {
            Color.izCanvas.opacity(0.8).ignoresSafeArea()
            VStack(spacing: 12) {
                ProgressView()
                    .tint(Color.izAccentLight)
                Text("Processing...")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.izTextSecondary)
            }
        }
    }

    private func purchase() {
        Haptics.tap()
        isPurchasing = true

        Task {
            do {
                var success = false
                if let pkg = selectedPackage {
                    success = try await paywall.purchase(package: pkg)
                }

                await MainActor.run {
                    isPurchasing = false
                    if success {
                        store.showToast("Welcome to Pro!", icon: "crown.fill")
                        dismiss()
                    }
                }
            } catch {
                await MainActor.run {
                    isPurchasing = false
                    errorMessage = error.localizedDescription
                    store.showToast("Purchase failed", icon: "xmark.circle")
                }
            }
        }
    }
}
