import Foundation

enum EmailCategory: String, CaseIterable, Codable, Identifiable {
    case needsReply
    case newsletter
    case receipt
    case calendar
    case update
    case social
    case promotion
    case personal

    var id: String { rawValue }

    var title: String {
        switch self {
        case .needsReply: "Needs Reply"
        case .newsletter: "Newsletter"
        case .receipt: "Receipt"
        case .calendar: "Calendar"
        case .update: "Update"
        case .social: "Social"
        case .promotion: "Promotion"
        case .personal: "Personal"
        }
    }

    var icon: String {
        switch self {
        case .needsReply: "arrowshape.turn.up.left"
        case .newsletter: "newspaper"
        case .receipt: "doc.text"
        case .calendar: "calendar"
        case .update: "arrow.triangle.2.circlepath"
        case .social: "person.2"
        case .promotion: "tag"
        case .personal: "envelope"
        }
    }

    var color: String {
        switch self {
        case .needsReply: "izAccentLight"
        case .newsletter: "izTextSecondary"
        case .receipt: "izSuccess"
        case .calendar: "izAccent"
        case .update: "izTextSecondary"
        case .social: "izAccentLight"
        case .promotion: "izWarning"
        case .personal: "izAccentLight"
        }
    }
}

enum EmailPriority: String, Codable {
    case high, normal, low

    var label: String {
        switch self {
        case .high: "High"
        case .normal: "Normal"
        case .low: "Low"
        }
    }
}

struct Email: Identifiable, Hashable, Codable {
    let id: UUID
    var senderName: String
    var senderEmail: String
    var subject: String
    var preview: String
    var body: String
    var date: Date
    var isRead: Bool
    var isStarred: Bool
    var category: EmailCategory
    var priority: EmailPriority
    var aiSummary: String?
    var aiSuggestedReply: String?

    init(
        id: UUID = UUID(),
        senderName: String,
        senderEmail: String,
        subject: String,
        preview: String,
        body: String,
        date: Date,
        isRead: Bool = false,
        isStarred: Bool = false,
        category: EmailCategory = .personal,
        priority: EmailPriority = .normal,
        aiSummary: String? = nil,
        aiSuggestedReply: String? = nil
    ) {
        self.id = id
        self.senderName = senderName
        self.senderEmail = senderEmail
        self.subject = subject
        self.preview = preview
        self.body = body
        self.date = date
        self.isRead = isRead
        self.isStarred = isStarred
        self.category = category
        self.priority = priority
        self.aiSummary = aiSummary
        self.aiSuggestedReply = aiSuggestedReply
    }
}

struct ToastModel: Identifiable, Equatable {
    let id = UUID()
    var message: String
    var icon: String

    static func == (lhs: ToastModel, rhs: ToastModel) -> Bool {
        lhs.id == rhs.id
    }
}
