import SwiftUI

// MARK: - Main Content View

struct ContentView: View {
    @StateObject private var settings = DiscoSettings()

    @State private var showingDisco = false
    @State private var showingColorPicker = false
    @State private var showingSafetyWarning = false
    @AppStorage("hasSeenSafetyWarning") private var hasSeenSafetyWarning = false

    var body: some View {
        ZStack {
            // Deep dark background
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 28) {

                    // MARK: Header
                    VStack(spacing: 4) {
                        Text("🪩")
                            .font(.system(size: 64))
                        Text("Disco Lights")
                            .font(.system(size: 34, weight: .black))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 20)

                    // MARK: Mode Picker
                    SectionCard(title: "MODE") {
                        VStack(spacing: 0) {
                            ForEach(DiscoMode.allCases) { mode in
                                ModeRow(
                                    mode: mode,
                                    isSelected: settings.mode == mode
                                ) {
                                    settings.mode = mode
                                }
                                if mode != DiscoMode.allCases.last {
                                    Divider().background(Color.white.opacity(0.1))
                                }
                            }
                        }
                    }

                    // MARK: BPM Slider (hidden for beat reactive)
                    if settings.mode != .beatReactive {
                        SectionCard(title: "BPM  —  \(Int(settings.bpm))") {
                            VStack(spacing: 10) {
                                Slider(value: $settings.bpm, in: 30...300, step: 1)
                                    .tint(.purple)

                                HStack {
                                    Text("30").foregroundColor(.gray)
                                    Spacer()
                                    Text("Slow")
                                        .foregroundColor(bpmLabel.color)
                                        .font(.caption.bold())
                                    Text("·")
                                        .foregroundColor(.gray)
                                    Text(bpmLabel.name)
                                        .foregroundColor(bpmLabel.color)
                                        .font(.caption.bold())
                                    Spacer()
                                    Text("300").foregroundColor(.gray)
                                }
                                .font(.caption)
                            }
                            .padding(.horizontal, 4)
                        }
                    }

                    // MARK: Beat Sensitivity (only for beat reactive)
                    if settings.mode == .beatReactive {
                        SectionCard(title: "SENSITIVITY") {
                            VStack(spacing: 10) {
                                Slider(value: $settings.beatSensitivity, in: 1.1...3.0, step: 0.1)
                                    .tint(.cyan)
                                HStack {
                                    Text("Sensitive").foregroundColor(.gray)
                                    Spacer()
                                    Text("🎤 Listening for ambient sound").foregroundColor(.cyan)
                                    Spacer()
                                    Text("Selective").foregroundColor(.gray)
                                }
                                .font(.caption)
                            }
                            .padding(.horizontal, 4)
                        }
                    }

                    // MARK: Color Palette
                    SectionCard(title: "COLORS") {
                        VStack(spacing: 12) {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                                ForEach(ColorPalette.allCases) { palette in
                                    PaletteCard(
                                        palette: palette,
                                        isSelected: settings.selectedPalette == palette,
                                        customColors: settings.customColors
                                    ) {
                                        settings.selectedPalette = palette
                                        if palette == .custom {
                                            showingColorPicker = true
                                        }
                                    }
                                }
                            }

                            if settings.selectedPalette == .custom {
                                Button {
                                    showingColorPicker = true
                                } label: {
                                    Label(
                                        settings.customColors.isEmpty
                                            ? "Add Colors to your palette"
                                            : "Edit Custom Colors (\(settings.customColors.count))",
                                        systemImage: "paintpalette"
                                    )
                                    .font(.subheadline)
                                    .foregroundColor(.purple)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(Color.purple.opacity(0.15))
                                    .cornerRadius(10)
                                }
                            }
                        }
                    }

                    // MARK: Go Button
                    Button {
                        if hasSeenSafetyWarning {
                            showingDisco = true
                        } else {
                            showingSafetyWarning = true
                        }
                    } label: {
                        HStack {
                            Text("GO!")
                                .font(.system(size: 28, weight: .black))
                            Text("🕺")
                                .font(.system(size: 28))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(
                            LinearGradient(
                                colors: settings.canGo
                                    ? [.yellow, .orange, .pink]
                                    : [.gray.opacity(0.4), .gray.opacity(0.3)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(20)
                    }
                    .disabled(!settings.canGo)
                    .padding(.horizontal)
                    .padding(.bottom, 40)

                    if !settings.canGo {
                        Text("Add at least one color to your custom palette to continue.")
                            .font(.caption)
                            .foregroundColor(.orange)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                    }
                }
                .padding(.horizontal)
            }
        }
        .fullScreenCover(isPresented: $showingDisco) {
            DiscoModeView(settings: settings)
        }
        .sheet(isPresented: $showingColorPicker) {
            CustomColorPickerView(colors: $settings.customColors)
        }
        .sheet(isPresented: $showingSafetyWarning) {
            SafetyWarningView {
                hasSeenSafetyWarning = true
                showingSafetyWarning = false
                showingDisco = true
            }
        }
    }

    // MARK: - BPM Label

    private var bpmLabel: (name: String, color: Color) {
        switch settings.bpm {
        case ..<60: return ("Chill", .blue)
        case 60..<100: return ("Groovy", .green)
        case 100..<140: return ("Dancing", .yellow)
        case 140..<180: return ("Hype", .orange)
        default: return ("CHAOS", .red)
        }
    }
}

// MARK: - Section Card

struct SectionCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundColor(.gray)
                .tracking(1.5)

            content
                .padding()
                .background(Color.white.opacity(0.07))
                .cornerRadius(14)
        }
    }
}

// MARK: - Mode Row

struct ModeRow: View {
    let mode: DiscoMode
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: mode.icon)
                    .font(.title3)
                    .foregroundColor(isSelected ? .purple : .gray)
                    .frame(width: 30)

                VStack(alignment: .leading, spacing: 2) {
                    Text(mode.rawValue)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(mode.description)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.purple)
                }
            }
            .padding(.vertical, 10)
        }
    }
}

// MARK: - Palette Card

struct PaletteCard: View {
    let palette: ColorPalette
    let isSelected: Bool
    let customColors: [Color]
    let action: () -> Void

    private var displayColors: [Color] {
        palette == .custom
            ? (customColors.isEmpty ? [Color.gray.opacity(0.3)] : Array(customColors.prefix(4)))
            : Array(palette.colors.prefix(4))
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(palette.icon)
                    .font(.system(size: 22))

                HStack(spacing: 4) {
                    ForEach(Array(displayColors.enumerated()), id: \.offset) { _, color in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(color)
                            .frame(height: 20)
                    }
                }

                Text(palette.rawValue)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(isSelected ? .white : .gray)
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.purple.opacity(0.25) : Color.white.opacity(0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.purple : Color.clear, lineWidth: 1.5)
                    )
            )
        }
    }
}
