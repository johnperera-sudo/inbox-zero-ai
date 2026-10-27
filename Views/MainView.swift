import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case inbox, brief, upgrade

    var id: String { rawValue }

    var title: String {
        switch self {
        case .inbox: "Inbox"
        case .brief: "Brief"
        case .upgrade: "Upgrade"
        }
    }

    var icon: String {
        switch self {
        case .inbox: "tray"
        case .brief: "doc.text"
        case .upgrade: "crown"
        }
    }
}

struct MainView: View {
    @ObservedObject var store: MailboxStore
    @ObservedObject var paywall: PaywallManager
    @State private var tab: AppTab = .inbox
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            ZStack(alignment: .bottom) {
                Color.izCanvas.ignoresSafeArea()

                Group {
                    switch tab {
                    case .inbox:
                        InboxView(store: store, paywall: paywall)
                    case .brief:
                        DailyBriefView(store: store)
                    case .upgrade:
                        UpgradeView(store: store, paywall: paywall)
                    }
                }
                .safeAreaPadding(.bottom, path.isEmpty && tab != .upgrade ? 108 : 0)
                .animation(.snappy(duration: 0.25), value: path.isEmpty)

                if path.isEmpty {
                    VStack(spacing: 10) {
                        if tab == .inbox {
                            MicHoldButton(store: store)
                        }
                        tabBar
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .toolbar(.hidden, for: .navigationBar, .tabBar)
            .navigationDestination(for: Email.self) { email in
                MailDetailView(store: store, email: email)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .environment(\.izNavigate, NavigateAction { email in path.append(email) })
        .preferredColorScheme(.dark)
        .sheet(isPresented: $store.showPaywall) {
            PaywallView(paywall: paywall, store: store)
        }
        .fullScreenCover(isPresented: $store.showVoiceOverlay) {
            VoiceCommandOverlay(store: store, isPresented: $store.showVoiceOverlay)
        }
        .overlay(alignment: .top) {
            if let toast = store.toast {
                ToastView(toast: toast)
                    .padding(.top, 8)
                    .task {
                        try? await Task.sleep(for: .seconds(2.6))
                        withAnimation(.snappy) { store.toast = nil }
                    }
            }
        }
    }

    private var tabBar: some View {
        HStack(spacing: 4) {
            ForEach(AppTab.allCases) { t in
                tabButton(t)
            }
        }
        .padding(6)
        .background(
            Capsule()
                .fill(Color.izSurface.opacity(0.92))
                .overlay(
                    Capsule().strokeBorder(Color.izHairline, lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.4), radius: 18, y: 8)
        )
        .padding(.horizontal, 48)
        .padding(.bottom, 8)
    }

    private func tabButton(_ t: AppTab) -> some View {
        let selected = tab == t
        return Button {
            Haptics.tap()
            withAnimation(.snappy(duration: 0.25)) { tab = t }
        } label: {
            VStack(spacing: 3) {
                Image(systemName: t.icon)
                    .font(.system(size: 17, weight: .semibold))
                Text(t.title)
                    .font(.system(size: 11, weight: .medium))
            }
            .foregroundStyle(selected ? Color.izAccentLight : Color.izTextSecondary)
            .frame(maxWidth: .infinity)
            .frame(height: 46)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(selected ? Color.izAccent.opacity(0.28) : .clear)
            )
        }
        .buttonStyle(.plain)
    }

    private var micButton: some View {
        MicHoldButton(store: store).padding(.bottom, 4)
    }
}
