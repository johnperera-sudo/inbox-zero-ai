import SwiftUI

struct ToastView: View {
    let toast: ToastModel

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: toast.icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.izAccentLight)

            Text(toast.message)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.izText)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(Color.izSurface.opacity(0.96))
                .overlay(Capsule().strokeBorder(Color.izHairline, lineWidth: 1))
                .shadow(color: .black.opacity(0.3), radius: 12, y: 4)
        )
        .padding(.horizontal, 24)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}
