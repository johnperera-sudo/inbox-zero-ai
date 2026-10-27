import SwiftUI

extension Color {
    static let izCanvas = Color("izCanvas")
    static let izSurface = Color("izSurface")
    static let izHairline = Color("izHairline")
    static let izAccent = Color("izAccent")
    static let izAccentLight = Color("izAccentLight")
    static let izText = Color("izText")
    static let izTextSecondary = Color("izTextSecondary")
    static let izSuccess = Color("izSuccess")
    static let izWarning = Color("izWarning")
    static let izError = Color("izError")
}

extension View {
    func safeAreaPadding(_ edges: Edge.Set, _ length: CGFloat) -> some View {
        padding(edges, length)
    }
}
