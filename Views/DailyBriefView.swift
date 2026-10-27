import SwiftUI

struct DailyBriefView: View {
    @ObservedObject var store: MailboxStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                statsRow
                needsReplySection
                todaySection
                cleanUpSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .background(Color.izCanvas.ignoresSafeArea())
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(Date().formatted(.dateTime.weekday(.wide).month(.abbreviated).day()))
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.izAccentLight)

            Text("Daily Brief")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(Color.izText)

            Text("Your inbox, summarized by AI")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.izTextSecondary)
        }
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            statCard("\(store.unreadCount)", label: "Unread", icon: "envelope.badge")
            statCard("\(store.needsReplyCount)", label: "Need Reply", icon: "arrowshape.turn.up.left")
            statCard("\(store.emails.filter { $0.category == .calendar }.count)", label: "Events", icon: "calendar")
        }
    }

    private func statCard(_ value: String, label: String, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.izAccentLight)

            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Color.izText)

            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color.izTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.izSurface.opacity(0.6))
                .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.izHairline, lineWidth: 1))
        )
    }

    private var needsReplySection: some View {
        let needsReply = store.emails.filter { $0.category == .needsReply }
        return briefSection(
            title: "Needs Your Attention",
            icon: "arrowshape.turn.up.left.fill",
            color: Color.izAccentLight
        ) {
            if needsReply.isEmpty {
                Text("No emails need a reply. You're all caught up.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.izTextSecondary)
            } else {
                VStack(spacing: 12) {
                    ForEach(needsReply) { email in
                        briefItem(email)
                    }
                }
            }
        }
    }

    private var todaySection: some View {
        let today = store.emails.filter { Calendar.current.isDateInToday($0.date) }
        return briefSection(
            title: "Today's Mail",
            icon: "tray.fill",
            color: Color.izAccent
        ) {
            if today.isEmpty {
                Text("No new mail today.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.izTextSecondary)
            } else {
                VStack(spacing: 12) {
                    ForEach(today) { email in
                        briefItem(email)
                    }
                }
            }
        }
    }

    private var cleanUpSection: some View {
        let newsletters = store.emails.filter { $0.category == .newsletter || $0.category == .promotion }
        let count = newsletters.count
        return briefSection(
            title: "AI Cleanup Suggestion",
            icon: "sparkles",
            color: Color.izAccentLight
        ) {
            VStack(alignment: .leading, spacing: 12) {
                Text("\(count) newsletters and promotions can be archived. That's \(count) emails cluttering your inbox that don't need a response.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.izText)
                    .multilineTextAlignment(.leading)

                Button {
                    Haptics.tap()
                    for email in newsletters {
                        store.archive(email)
                    }
                    store.showToast("Cleaned up \(count) emails", icon: "sparkles")
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "archivebox.fill")
                            .font(.system(size: 13, weight: .semibold))
                        Text("Archive All")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundStyle(Color.izCanvas)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(Capsule().fill(Color.izAccent))
                }
                .buttonStyle(.plain)
                .disabled(count == 0)
                .opacity(count == 0 ? 0.4 : 1)
            }
        }
    }

    private func briefSection<Content: View>(
        title: String,
        icon: String,
        color: Color,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(color)
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.izText)
            }

            content()
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.izSurface.opacity(0.5))
                .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(Color.izHairline, lineWidth: 1))
        )
    }

    private func briefItem(_ email: Email) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: email.category.icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.izTextSecondary)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 3) {
                Text(email.senderName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.izText)
                    .lineLimit(1)

                if let summary = email.aiSummary {
                    Text(summary)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(Color.izTextSecondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                } else {
                    Text(email.subject)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(Color.izTextSecondary)
                        .lineLimit(2)
                }
            }

            Spacer()
        }
    }
}
