import SwiftUI

struct MicHoldButton: View {
    @ObservedObject var store: MailboxStore

    var body: some View {
        Button {
            Haptics.tap()
            store.showVoiceOverlay = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "mic.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.izCanvas)

                Text("Hold to Speak")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.izCanvas)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(Color.izAccent)
                    .shadow(color: Color.izAccent.opacity(0.4), radius: 12, y: 4)
            )
        }
        .buttonStyle(.plain)
    }
}
