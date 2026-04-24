import SwiftUI

// MARK: - Disco Mode View

struct DiscoModeView: View {
    @ObservedObject var settings: DiscoSettings
    @Environment(\.dismiss) var dismiss
    @Environment(\.scenePhase) var scenePhase

    @State private var currentColor: Color = .black
    @State private var colorIndex = 0
    @State private var timer: Timer?
    @StateObject private var beatDetector = BeatDetector()

    /// Saved brightness so we can restore it on exit
    @State private var originalBrightness: CGFloat = UIScreen.main.brightness

    private var colors: [Color] { settings.activeColors }

    var body: some View {
        currentColor
            .ignoresSafeArea()
            .overlay(alignment: .bottom) {
                Button {
                    exitDisco()
                } label: {
                    Image(systemName: "stop.circle.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(.white.opacity(0.25))
                }
                .padding(.bottom, 48)
            }
            .onTapGesture(count: 2) {
                exitDisco()
            }
            .statusBarHidden(true)
            .persistentSystemOverlays(.hidden)
            .onAppear {
                startDisco()
            }
            .onDisappear {
                tearDown()
            }
            .onChange(of: scenePhase) { _, newPhase in
                // If app backgrounds while disco is running, tear down and restore
                if newPhase != .active {
                    tearDown()
                }
            }
            // Handle mic permission denial
            .overlay {
                if settings.mode == .beatReactive && beatDetector.permissionState == .denied {
                    micPermissionDeniedOverlay
                }
            }
    }

    // MARK: - Mic Permission Denied Overlay

    private var micPermissionDeniedOverlay: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()
            VStack(spacing: 20) {
                Image(systemName: "mic.slash.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.red)

                Text("Microphone Access Denied")
                    .font(.title2.bold())
                    .foregroundColor(.white)

                Text("Beat Reactive mode needs microphone access. Please allow it in Settings.")
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Label("Open Settings", systemImage: "gear")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .cornerRadius(12)
                }

                Button("Go Back") { exitDisco() }
                    .foregroundColor(.gray)
            }
            .padding()
        }
    }

    // MARK: - Disco Lifecycle

    private func startDisco() {
        guard !colors.isEmpty else {
            exitDisco()
            return
        }

        originalBrightness = UIScreen.main.brightness
        UIScreen.main.brightness = 1.0
        UIApplication.shared.isIdleTimerDisabled = true

        colorIndex = 0
        currentColor = colors[0]

        switch settings.mode {
        case .ordered:
            startTimerMode(random: false)
        case .random:
            startTimerMode(random: true)
        case .beatReactive:
            startBeatReactiveMode()
        }
    }

    private func startTimerMode(random: Bool) {
        let interval = 60.0 / settings.bpm
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            flashNextColor(random: random)
        }
    }

    private func startBeatReactiveMode() {
        beatDetector.sensitivity = Float(settings.beatSensitivity)
        beatDetector.checkCurrentPermission()

        switch beatDetector.permissionState {
        case .granted:
            beatDetector.onBeat = { flashNextColor(random: true) }
            beatDetector.start()
        case .undetermined:
            beatDetector.requestPermission { granted in
                if granted {
                    self.beatDetector.onBeat = { self.flashNextColor(random: true) }
                    self.beatDetector.start()
                }
                // If denied, the overlay will appear automatically via permissionState
            }
        case .denied:
            break // overlay handles this
        }
    }

    private func flashNextColor(random: Bool) {
        if random {
            currentColor = colors.randomElement() ?? .black
        } else {
            colorIndex = (colorIndex + 1) % colors.count
            currentColor = colors[colorIndex]
        }
    }

    private func exitDisco() {
        tearDown()
        dismiss()
    }

    private func tearDown() {
        timer?.invalidate()
        timer = nil
        beatDetector.stop()
        UIApplication.shared.isIdleTimerDisabled = false
        UIScreen.main.brightness = originalBrightness
    }
}
