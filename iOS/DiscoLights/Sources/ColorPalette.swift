import SwiftUI

// MARK: - Color Palette

enum ColorPalette: String, CaseIterable, Identifiable {
    case disco = "Disco"
    case neon = "Neon"
    case fire = "Fire"
    case ocean = "Ocean"
    case custom = "Custom"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .disco: return "🕺"
        case .neon: return "💚"
        case .fire: return "🔥"
        case .ocean: return "🌊"
        case .custom: return "🎨"
        }
    }

    var colors: [Color] {
        switch self {
        case .disco:
            return [.red, .blue, .yellow, .green, .purple, .pink, .orange, .white]
        case .neon:
            return [
                Color(red: 0.0, green: 1.0, blue: 0.2),
                Color(red: 1.0, green: 0.0, blue: 1.0),
                Color(red: 0.0, green: 1.0, blue: 1.0),
                Color(red: 1.0, green: 1.0, blue: 0.0)
            ]
        case .fire:
            return [
                Color(red: 1.0, green: 0.0, blue: 0.0),
                Color(red: 1.0, green: 0.4, blue: 0.0),
                Color(red: 1.0, green: 0.7, blue: 0.0),
                Color(red: 1.0, green: 1.0, blue: 0.0)
            ]
        case .ocean:
            return [
                Color(red: 0.0, green: 0.3, blue: 1.0),
                Color(red: 0.0, green: 0.8, blue: 1.0),
                Color(red: 0.0, green: 1.0, blue: 0.8),
                Color(red: 0.2, green: 0.5, blue: 1.0)
            ]
        case .custom:
            return []
        }
    }
}
