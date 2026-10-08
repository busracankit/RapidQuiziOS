import SwiftUI

/// Tasarım tokenları (dokümanın 6. bölümü). Yalnızca açık tema.
extension Color {
    static let rqBackground = Color(hex: "#FFF8F1")
    static let rqSurface = Color(hex: "#FFFFFF")
    static let rqInk = Color(hex: "#1E1B4B")
    static let rqPrimary = Color(hex: "#7C3AED")
    static let rqAccent = Color(hex: "#FF4D8D")
    static let rqSuccess = Color(hex: "#22C55E")
    static let rqDanger = Color(hex: "#EF4444")
    static let rqWarning = Color(hex: "#FACC15")

    // Podyum
    static let rqGold = Color(hex: "#F5B301")
    static let rqSilver = Color(hex: "#A8B0BD")
    static let rqBronze = Color(hex: "#CD7F32")

    /// "#RRGGBB" biçimindeki rengi çözer. Hatalı değerde `rqPrimary` (#7C3AED) döner.
    init(hex: String) {
        var value = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if value.hasPrefix("#") { value.removeFirst() }
        guard value.count == 6, let rgb = UInt32(value, radix: 16) else {
            self = Color(.sRGB, red: 0x7C / 255, green: 0x3A / 255, blue: 0xED / 255)
            return
        }
        self = Color(
            .sRGB,
            red: Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >> 8) & 0xFF) / 255,
            blue: Double(rgb & 0xFF) / 255
        )
    }
}
