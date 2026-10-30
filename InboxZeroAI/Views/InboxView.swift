import SwiftUI

struct InboxView: View {
    @ObservedObject var store: MailboxStore
    @ObservedObject var paywall: PaywallManager
    @Environment(\.izNavigate) private var navigate
    @State private var filter: EmailCategory?
    @State private var showFilterSheet = false

    var filteredEmails: [Email] {
        if let filter {
            store.emails.filter { $0.category == filter }
        } else {
            store.emails
        }
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                headerSection

                if filteredEmails.isEmpty {
                    emptyState
                } else {
                    ForEach(filteredEmails) { email in
                        emailRow(email)
                    }
                }
            }
            .padding(.top, 8)
        }
        .scrollIndicators(.hidden)
        .background(Color.izCanvas.ignoresSafeArea())
        .animation(.snappy(duration: 0.25), value: filter)
    }

    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Inbox")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(Color.izText)

                    Text("\(store.unreadCount) unread · \(store.needsReplyCount) need reply")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.izTextSecondary)
                }

                Spacer()

                Button {
                    Haptics.tap()
                    showFilterSheet = true
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(Color.izAccentLight)
                }
                .buttonStyle(.plain)
                .confirmationDialog("Filter", isPresented: $showFilterSheet) {
                    Button("All Mail") { filter = nil }
                    ForEach(EmailCategory.allCases) { cat in
                        Button(cat.title) { filter = cat }
                    }
                    Button("Cancel", role: .cancel) {}
                }
            }

            if let filter {
                filterChip
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
    }

    private var filterChip: some View {
        HStack(spacing: 6) {
            Image(systemName: filter?.icon ?? "tray"))
                .font(.system(size: 11, weight: .semibold))
            Text(filter.title)
                .font(.system(size: 13, weight: .semibold))
            Button {
                withAnimation { filter = nil }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.izTextSecondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.izAccent.opacity(0.18))
                .overlay(Capsule().strokeBorder(Color.izHairline, lineWidth: 1))
        )
        .foregroundStyle(Color.izAccentLight)
        .transition(.opacity.combined(with: .scale))
    }

    private func emailRow(_ email: Email) -> some View {
        Button {
            store.markRead(email)
            navigate(email)
        } label: {
            EmailRow(email: email)
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .trailing) {
            Button {
                paywall.increment()
                if paywall.shouldShowPaywall() {
                    store.showPaywall = true
                }
                store.archive(email)
            } label: {
                Label("Archive", systemImage: "archivebox")
            }
            .tint(Color.izSurface)

            Button(role: .destructive) {
                paywall.increment()
                if paywall.shouldShowPaywall() {
                    store.showPaywall = true
                }
                store.deleteEmail(email)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .swipeActions(edge: .leading) {
            Button {
                paywall.increment()
                if paywall.shouldShowPaywall() {
                    store.showPaywall = true
                }
                store.snooze(email)
            } label: {
                Label("Snooze", systemImage: "clock.badge")
            }
            .tint(Color.izAccent)

            Button {
                store.toggleStar(email)
            } label: {
                Label(email.isStarred ? "Unstar" : "Star",
                      systemImage: email.isStarred ? "star.slash" : "star.fill")
            }
            .tint(Color.izWarning)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer(minLength: 80)

            Image(systemName: "tray.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.izTextSecondary.opacity(0.5))

            Text("Inbox Zero")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color.izText)

            Text("You're all caught up. Nothing to do here.")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.izTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
}

struct EmailRow: View {
    let email: Email

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            avatar

            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 6) {
                    if !email.isRead {
                        Circle()
                            .fill(Color.izAccentLight)
                            .frame(width: 7, height: 7)
                    }

                    Text(email.senderName)
                        .font(.system(size: 15, weight: email.isRead ? .medium : .bold))
                        .foregroundStyle(email.isRead ? Color.izTextSecondary : Color.izText)
                        .lineLimit(1)

                    Spacer()

                    Text(email.date.formatted(.relative(presentation: .named)))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.izTextSecondary)
                }

                Text(email.subject)
                    .font(.system(size: 14, weight: email.isRead ? .medium : .semibold))
                    .foregroundStyle(email.isRead ? Color.izTextSecondary : Color.izText)
                    .lineLimit(1)

                Text(email.preview)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color.izTextSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                HStack(spacing: 6) {
                    categoryTag

                    if email.isStarred {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(Color.izWarning)
                    }

                    if email.priority == .high {
                        Text("High Priority")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color.izError)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Color.izError.opacity(0.18)))
                    }
                }
                .padding(.top, 2)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .overlay(
            Rectangle()
                .fill(Color.izHairline.opacity(0.5))
                .frame(height: 0.5),
            alignment: .bottom
        )
        .contentShape(Rectangle())
    }

    private var avatar: some View {
        let initials = String(email.senderName.prefix(1)).uppercased()
        return ZStack {
            Circle()
                .fill(Color.izAccent.opacity(0.25))
            Text(initials)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color.izAccentLight)
        }
        .frame(width: 40, height: 40)
    }

    private var categoryTag: some View {
        HStack(spacing: 4) {
            Image(systemName: email.category.icon)
                .font(.system(size: 9, weight: .semibold))
            Text(email.category.title)
                .font(.system(size: 10, weight: .semibold))
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 3)
        .background(
            Capsule()
                .fill(Color.izSurface.opacity(0.8))
                .overlay(Capsule().strokeBorder(Color.izHairline, lineWidth: 0.5))
        )
        .foregroundStyle(Color.izTextSecondary)
    }
}
