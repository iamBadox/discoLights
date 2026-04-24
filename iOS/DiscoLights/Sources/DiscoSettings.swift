import SwiftUI
import Combine

// MARK: - Disco Mode

enum DiscoMode: String, CaseIterable, Identifiable {
    case ordered = "Ordered"
    case random = "Random"
    case beatReactive = "Beat Reactive"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .ordered: return "arrow.right.circle"
        case .random: return "shuffle"
        case .beatReactive: return "waveform.and.mic"
        }
    }

    var description: String {
        switch self {
        case .ordered: return "Colors cycle in sequence at your chosen BPM"
        case .random: return "Colors flash randomly at your chosen BPM"
        case .beatReactive: return "Colors change with ambient sound detected by the mic"
        }
    }
}

// MARK: - Disco Settings

class DiscoSettings: ObservableObject {
    @Published var mode: DiscoMode = .ordered
    @Published var bpm: Double = 120
    @Published var selectedPalette: ColorPalette = .disco
    @Published var customColors: [Color] = []
    @Published var beatSensitivity: Double = 1.5 // multiplier: higher = less sensitive

    var activeColors: [Color] {
        if selectedPalette == .custom {
            return customColors.isEmpty ? [] : customColors
        }
        return selectedPalette.colors
    }

    var canGo: Bool {
        !activeColors.isEmpty
    }
}
