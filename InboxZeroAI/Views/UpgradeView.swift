import SwiftUI

struct UpgradeView: View {
    @ObservedObject var store: MailboxStore
    @ObservedObject var paywall: PaywallManager

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                heroSection
                featuresSection
                ctaButton
                restoreLink
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .background(Color.izCanvas.ignoresSafeArea())
    }

    private var heroSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.izAccent.opacity(0.2))
                    .frame(width: 96, height: 96)

                Image(systemName: "crown.fill")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(Color.izAccentLight)
            }

            VStack(spacing: 6) {
                Text("InboxZeroAI Pro")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color.izText)

                Text("Unlimited AI triage, voice commands, and smart replies for your inbox.")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.izTextSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 20)
    }

    private var featuresSection: some View {
        VStack(spacing: 0) {
            featureRow(icon: "sparkles", title: "Unlimited AI Summaries", desc: "Every email, summarized in one tap — no daily limit.")
            featureRow(icon: "waveform", title: "Voice Commands", desc: "Sort, archive, and reply hands-free with your voice.")
            featureRow(icon: "arrowshape.turn.up.left", title: "Smart Replies", desc: "AI-drafted replies in your tone, ready to send.")
            featureRow(icon: "doc.text", title: "Daily AI Brief", desc: "A morning digest of what matters, what needs you, and what to ignore.")
            featureRow(icon: "shield.fill", title: "Priority Support", desc: "Fast-track responses from our team.", isLast: true)
        }
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.izSurface.opacity(0.5))
                .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(Color.izHairline, lineWidth: 1))
        )
    }

    private func featureRow(icon: String, title: String, desc: String, isLast: Bool = false) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.izAccent.opacity(0.18))
                        .frame(width: 38, height: 38)
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.izAccentLight)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.izText)
                    Text(desc)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(Color.izTextSecondary)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(Color.izSuccess)
            }
            .padding(16)

            if !isLast {
                Rectangle()
                    .fill(Color.izHairline.opacity(0.5))
                    .frame(height: 0.5)
                    .padding(.leading, 68)
            }
        }
    }

    private var ctaButton: some View {
        Button {
            Haptics.tap()
            store.showPaywall = true
        } label: {
            VStack(spacing: 2) {
                Text("Upgrade to Pro")
                    .font(.system(size: 17, weight: .bold))
                Text("$9.99 / month")
                    .font(.system(size: 13, weight: .medium))
            }
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
    }

    private var restoreLink: some View {
        Button {
            Haptics.tap()
            Task {
                do {
                    let restored = try await paywall.restorePurchases()
                    if restored {
                        store.showToast("Pro restored!", icon: "crown.fill")
                    } else {
                        store.showToast("No purchases found", icon: "exclamationmark.circle")
                    }
                } catch {
                    store.showToast("Restore failed", icon: "xmark.circle")
                }
            }
        } label: {
            Text("Restore Purchases")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.izTextSecondary)
        }
        .buttonStyle(.plain)
    }
}
