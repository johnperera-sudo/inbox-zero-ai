import Foundation
import SwiftUI

@MainActor
final class MailboxStore: ObservableObject {
    @Published var emails: [Email] = []
    @Published var toast: ToastModel?
    @Published var showPaywall: Bool = false
    @Published var showVoiceOverlay: Bool = false
    @Published var isLoading: Bool = false

    init() {
        loadSeedData()
    }

    private func loadSeedData() {
        let now = Date()
        let cal = Calendar.current

        emails = [
            Email(
                senderName: "Sarah Chen",
                senderEmail: "sarah.chen@designstudio.co",
                subject: "Re: Q4 Brand Refresh — Final Review",
                preview: "Attached are the final mockups for the brand refresh. Can you review by Friday so we can send to print?",
                body: "Hi,\n\nAttached are the final mockups for the brand refresh. Can you review by Friday so we can send to print?\n\nA few things to note:\n• The primary palette has shifted to a warmer neutral\n• Logo lockup options A and B are included\n• Typography is finalized as Söhne + Tiempos\n\nLet me know if you have any concerns.\n\nBest,\nSarah",
                date: cal.date(byAdding: .minute, value: -12, to: now)!,
                isRead: false,
                category: .needsReply,
                priority: .high,
                aiSummary: "Sarah needs your approval on final brand mockups by Friday. Three changes noted: warmer palette, two logo options, typography finalized.",
                aiSuggestedReply: "Hi Sarah, the mockups look great. I'll review them by Thursday and get back to you with feedback. Thanks for the detailed notes!"
            ),
            Email(
                senderName: "Stripe",
                senderEmail: "receipts@stripe.com",
                subject: "Receipt for your payment — $29.00",
                preview: "You were charged $29.00 for your monthly subscription. View your receipt here.",
                body: "You were charged $29.00 for your monthly subscription.\n\nDate: October 26, 2026\nAmount: $29.00\nCard: •••• 4242\n\nView full receipt at stripe.com/receipts",
                date: cal.date(byAdding: .hour, value: -3, to: now)!,
                isRead: true,
                category: .receipt,
                priority: .low,
                aiSummary: "Automated receipt for $29.00 monthly subscription charge. No action needed."
            ),
            Email(
                senderName: "The Hustle",
                senderEmail: "newsletter@thehustle.co",
                subject: "The 3 startups redefining email in 2026",
                preview: "Plus: Why AI triage is eating the $80B productivity market, and a deep dive on ambient assistants.",
                body: "Today's top stories:\n\n1. The 3 startups redefining email in 2026\n2. Why AI triage is eating the $80B productivity market\n3. A deep dive on ambient assistants\n\nRead more at thehustle.co",
                date: cal.date(byAdding: .hour, value: -5, to: now)!,
                isRead: true,
                category: .newsletter,
                priority: .low,
                aiSummary: "Newsletter roundup. Key story: AI triage tools are capturing the productivity market. Skim-worthy."
            ),
            Email(
                senderName: "Google Calendar",
                senderEmail: "noreply@calendar.google.com",
                subject: "Event reminder: 1:1 with Marcus — Tomorrow 2:00 PM",
                preview: "You have a 1:1 meeting with Marcus tomorrow at 2:00 PM. View agenda.",
                body: "Event: 1:1 with Marcus\nWhen: Tomorrow, 2:00 PM - 2:30 PM\nWhere: Google Meet\n\nAgenda: Q4 goals review, team updates, hiring plan discussion.",
                date: cal.date(byAdding: .hour, value: -6, to: now)!,
                isRead: false,
                category: .calendar,
                priority: .normal,
                aiSummary: "Reminder: 1:1 with Marcus tomorrow 2:00 PM. Agenda covers Q4 goals, team updates, and hiring."
            ),
            Email(
                senderName: "Marcus Webb",
                senderEmail: "marcus@company.com",
                subject: "Quick question on the pricing deck",
                preview: "Can you share the latest version of the pricing deck before the board meeting? I want to double-check the unit economics slide.",
                body: "Hey,\n\nCan you share the latest version of the pricing deck before the board meeting? I want to double-check the unit economics slide.\n\nThanks,\nMarcus",
                date: cal.date(byAdding: .hour, value: -8, to: now)!,
                isRead: false,
                isStarred: true,
                category: .needsReply,
                priority: .high,
                aiSummary: "Marcus wants the latest pricing deck for board meeting prep. Needs the unit economics slide specifically.",
                aiSuggestedReply: "Hey Marcus, just sent over the latest pricing deck. Slide 12 has the updated unit economics. Let me know if anything looks off!"
            ),
            Email(
                senderName: "GitHub",
                senderEmail: "noreply@github.com",
                subject: "[inboxzeroai] 3 new pull requests need review",
                preview: "You have 3 pull requests awaiting review in inboxzeroai/inboxzeroai.",
                body: "Pull requests awaiting review:\n\n#142 — Add voice command overlay\n#143 — Fix tab bar transition on push\n#144 — RevenueCat entitlement check\n\nReview at github.com/inboxzeroai/inboxzeroai/pulls",
                date: cal.date(byAdding: .day, value: -1, to: now)!,
                isRead: true,
                category: .update,
                priority: .normal,
                aiSummary: "3 PRs awaiting review: voice overlay, tab bar fix, RevenueCat check. Blocker: #143 needs attention before release."
            ),
            Email(
                senderName: "Linear",
                senderEmail: "updates@linear.app",
                subject: "Weekly digest: 12 issues completed this week",
                preview: "Your team completed 12 issues this week. Sprint progress is at 78%.",
                body: "Weekly Summary:\n\nCompleted: 12 issues\nIn Progress: 5 issues\nSprint Progress: 78%\n\nTop contributors: You (4), Marcus (3), Lena (3), Dev (2)",
                date: cal.date(byAdding: .day, value: -1, to: now)!,
                isRead: true,
                category: .update,
                priority: .low,
                aiSummary: "Weekly Linear digest: 12 issues done, sprint at 78%. Good velocity."
            ),
            Email(
                senderName: "Airbnb",
                senderEmail: "promo@airbnb.com",
                subject: "Weekend getaways under $200 near you",
                preview: "Discover stays within driving distance — all under $200 a night.",
                body: "Weekend getaways under $200:\n\n• Cozy cabin in Big Bear — $145/night\n• Modern loft downtown — $180/night\n• Lakefront cottage — $195/night\n\nBook at airbnb.com",
                date: cal.date(byAdding: .day, value: -2, to: now)!,
                isRead: true,
                category: .promotion,
                priority: .low,
                aiSummary: "Promotional email. Weekend stays under $200. Not urgent."
            ),
            Email(
                senderName: "Mom",
                senderEmail: "mom@gmail.com",
                subject: "Sunday dinner?",
                preview: "Are you coming over for dinner this Sunday? Dad is making his famous lasagna.",
                body: "Hi sweetie,\n\nAre you coming over for dinner this Sunday? Dad is making his famous lasagna.\n\nLet me know!\n\nLove,\nMom",
                date: cal.date(byAdding: .day, value: -2, to: now)!,
                isRead: false,
                isStarred: true,
                category: .personal,
                priority: .normal,
                aiSummary: "Mom asking about Sunday dinner. Dad making lasagna. Reply to confirm.",
                aiSuggestedReply: "Hi Mom, yes I'll be there! Can't wait for Dad's lasagna. See you Sunday around 5?"
            ),
            Email(
                senderName: "Figma",
                senderEmail: "team@figma.com",
                subject: "Lena commented on 'Onboarding Flow v3'",
                preview: "Lena: 'Should we add a progress indicator on step 2? Users might drop off here.'",
                body: "Lena commented on Onboarding Flow v3:\n\n'Should we add a progress indicator on step 2? Users might drop off here.'\n\nView and reply at figma.com",
                date: cal.date(byAdding: .day, value: -3, to: now)!,
                isRead: true,
                category: .update,
                priority: .normal,
                aiSummary: "Lena suggesting a progress indicator on onboarding step 2. Worth reviewing the drop-off data first."
            )
        ]
    }

    var unreadCount: Int {
        emails.filter { !$0.isRead }.count
    }

    var needsReplyCount: Int {
        emails.filter { $0.category == .needsReply && !$0.isRead }.count
    }

    func email(with id: UUID) -> Email? {
        emails.first { $0.id == id }
    }

    func markRead(_ email: Email) {
        if let idx = emails.firstIndex(where: { $0.id == email.id }) {
            emails[idx].isRead = true
        }
    }

    func toggleStar(_ email: Email) {
        if let idx = emails.firstIndex(where: { $0.id == email.id }) {
            emails[idx].isStarred.toggle()
            Haptics.soft()
        }
    }

    func archive(_ email: Email) {
        emails.removeAll { $0.id == email.id }
        showToast("Archived", icon: "archivebox")
    }

    func deleteEmail(_ email: Email) {
        emails.removeAll { $0.id == email.id }
        showToast("Deleted", icon: "trash")
    }

    func snooze(_ email: Email) {
        showToast("Snoozed until tomorrow", icon: "clock.badge")
    }

    func showToast(_ message: String, icon: String = "checkmark.circle.fill") {
        toast = ToastModel(message: message, icon: icon)
    }

    func processVoiceCommand(_ text: String) {
        let lowered = text.lowercased()
        if lowered.contains("archive") {
            if let first = emails.first {
                archive(first)
            }
        } else if lowered.contains("read") || lowered.contains("summary") || lowered.contains("brief") {
            showToast("Generating summary...", icon: "sparkles")
        } else if lowered.contains("reply") {
            if let needs = emails.first(where: { $0.category == .needsReply }) {
                showToast("Drafting reply to \(needs.senderName)", icon: "arrowshape.turn.up.left")
            }
        } else {
            showToast("Heard: \"\(text)\"", icon: "waveform")
        }
    }
}
