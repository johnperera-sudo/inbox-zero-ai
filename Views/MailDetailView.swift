import SwiftUI

struct MailDetailView: View {
    @ObservedObject var store: MailboxStore
    let email: Email

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection

                if let summary = email.aiSummary {
                    aiSummaryCard(summary)
                }

                if let reply = email.aiSuggestedReply {
                    aiReplyCard(reply)
                }

                emailBody

                actionButtons
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .background(Color.izCanvas.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .overlay(alignment: .topLeading) {
            backButton
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: email.category.icon)
                    .font(.system(size: 10, weight: .semibold))
                Text(email.category.title)
                    .font(.system(size: 11, weight: .semibold))
                Spacer()
                if email.isStarred {
                    Image(systemName: "star.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.izWarning)
                }
            }
            .foregroundStyle(Color.izTextSecondary)

            Text(email.subject)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Color.izText)
                .multilineTextAlignment(.leading)

            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.izAccent.opacity(0.25))
                    Text(String(email.senderName.prefix(1)).uppercased())
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.izAccentLight)
                }
                .frame(width: 40, height: 40)

                VStack(alignment: .leading, spacing: 2) {
                    Text(email.senderName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.izText)
                    Text(email.senderEmail)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.izTextSecondary)
                }

                Spacer()

                Text(email.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.izTextSecondary)
            }
        }
    }

    private func aiSummaryCard(_ summary: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .font(.system(size: 12, weight: .bold))
                Text("AI Summary")
                    .font(.system(size: 12, weight: .bold))
            }
            .foregroundStyle(Color.izAccentLight)

            Text(summary)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.izText)
                .multilineTextAlignment(.leading)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.izAccent.opacity(0.12))
                .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.izHairline, lineWidth: 1))
        )
    }

    private func aiReplyCard(_ reply: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "arrowshape.turn.up.left.fill")
                    .font(.system(size: 12, weight: .bold))
                Text("Suggested Reply")
                    .font(.system(size: 12, weight: .bold))
            }
            .foregroundStyle(Color.izAccentLight)

            Text(reply)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(Color.izText)
                .multilineTextAlignment(.leading)

            Button {
                UIPasteboard.general.string = reply
                store.showToast("Reply copied", icon: "doc.on.doc.fill")
                Haptics.success()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 12, weight: .semibold))
                    Text("Copy")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundStyle(Color.izAccentLight)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.izAccent.opacity(0.18))
                )
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.izSurface.opacity(0.6))
                .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.izHairline, lineWidth: 1))
        )
    }

    private var emailBody: some View {
        Text(email.body)
            .font(.system(size: 15, weight: .regular))
            .foregroundStyle(Color.izText.opacity(0.9))
            .multilineTextAlignment(.leading)
            .lineSpacing(4)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            actionButton("Reply", icon: "arrowshape.turn.up.left", color: Color.izAccentLight) {
                store.showToast("Reply draft ready", icon: "arrowshape.turn.up.left")
            }
            actionButton("Forward", icon: "arrowshape.turn.up.right", color: Color.izTextSecondary) {
                store.showToast("Forwarding...", icon: "arrowshape.turn.up.right")
            }
        }
    }

    private func actionButton(_ title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button {
            Haptics.tap()
            action()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundStyle(color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.izSurface.opacity(0.8))
                    .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.izHairline, lineWidth: 1))
            )
        }
        .buttonStyle(.plain)
    }

    private var backButton: some View {
        Button {
            Haptics.tap()
            store.showToast("Archived", icon: "archivebox")
            store.archive(email)
        } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.izAccentLight)
                .frame(width: 36, height: 36)
                .background(Circle().fill(Color.izSurface.opacity(0.9)))
        }
        .buttonStyle(.plain)
        .padding(.leading, 20)
        .padding(.top, 8)
    }
}
