import SwiftUI

extension Color {
    init(hex: UInt32, alpha: Double = 1.0) {
        let red = Double((hex >> 16) & 0xFF) / 255.0
        let green = Double((hex >> 8) & 0xFF) / 255.0
        let blue = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}

struct AppColors {
    // Brand Yellows
    static let yellowPrimary = Color(hex: 0xFFFFDF00)
    static let yellowDark = Color(hex: 0xFFEAB308)
    static let yellowLight = Color(hex: 0xFFFEF9C3)
    static let yellowContainer = Color(hex: 0xFFFEF08A)

    // Capsule & Accents
    static let blueCapsule = Color(hex: 0xFF60A5FA)
    static let blueCapsuleLight = Color(hex: 0xFF93C5FD)
    static let blueText = Color(hex: 0xFF1E3A8A)

    // Card Gradients
    static let cardGreenStart = Color(hex: 0xFF86EFAC)
    static let cardGreenEnd = Color(hex: 0xFF22C55E)

    static let cardBlueStart = Color(hex: 0xFF7DD3FC)
    static let cardBlueEnd = Color(hex: 0xFF3B82F6)

    static let cardOrangeStart = Color(hex: 0xFDBA74)
    static let cardOrangeEnd = Color(hex: 0xFFF97316)

    static let cardPurpleStart = Color(hex: 0xD8B4FE)
    static let cardPurpleEnd = Color(hex: 0xFFA855F7)

    // Neutrals & System
    static let darkText = Color(hex: 0xFF0F172A)
    static let subtitleText = Color(hex: 0xFF64748B)
    static let lightBg = Color(hex: 0xFFF8FAFC)
    static let surfaceWhite = Color(hex: 0xFFFFFFFF)
    static let borderGray = Color(hex: 0xFFE2E8F0)
    static let successGreen = Color(hex: 0xFF10B981)
    static let destructiveRed = Color(hex: 0xFFEF4444)
}
