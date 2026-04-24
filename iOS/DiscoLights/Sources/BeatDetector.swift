import AVFoundation
import Combine

// MARK: - Microphone Beat Detector

class BeatDetector: ObservableObject {
    @Published var permissionState: PermissionState = .undetermined
    @Published var isListening = false

    var onBeat: (() -> Void)?

    private var audioEngine: AVAudioEngine?
    private var lastBeatTime: Date = .distantPast
    private var recentEnergies: [Float] = []

    /// Multiplier applied to rolling average to set beat threshold.
    /// Higher = less sensitive (fewer false positives).
    var sensitivity: Float = 1.5

    enum PermissionState {
        case undetermined, granted, denied
    }

    func requestPermission(completion: @escaping (Bool) -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
            DispatchQueue.main.async {
                self?.permissionState = granted ? .granted : .denied
                completion(granted)
            }
        }
    }

    func checkCurrentPermission() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted: permissionState = .granted
        case .denied: permissionState = .denied
        case .undetermined: permissionState = .undetermined
        @unknown default: permissionState = .undetermined
        }
    }

    func start() {
        guard permissionState == .granted else { return }
        stopEngine()

        let session = AVAudioSession.sharedInstance()
        do {
            // mixWithOthers lets music keep playing while we record mic input
            try session.setCategory(.playAndRecord, mode: .default, options: [.mixWithOthers, .defaultToSpeaker])
            try session.setActive(true)
        } catch {
            return
        }

        let engine = AVAudioEngine()
        let inputNode = engine.inputNode
        let format = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            self?.processBuffer(buffer)
        }

        do {
            try engine.start()
            audioEngine = engine
            DispatchQueue.main.async { self.isListening = true }
        } catch {
            return
        }
    }

    func stop() {
        stopEngine()
        DispatchQueue.main.async { self.isListening = false }
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    private func stopEngine() {
        audioEngine?.inputNode.removeTap(onBus: 0)
        audioEngine?.stop()
        audioEngine = nil
    }

    private func processBuffer(_ buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frameLength = Int(buffer.frameLength)

        // Calculate RMS energy of the buffer
        var sum: Float = 0
        for i in 0..<frameLength {
            sum += channelData[i] * channelData[i]
        }
        let rms = sqrt(sum / Float(max(frameLength, 1)))

        // Rolling window of ~1 second worth of frames
        recentEnergies.append(rms)
        if recentEnergies.count > 44 {
            recentEnergies.removeFirst()
        }

        let avgEnergy = recentEnergies.reduce(0, +) / Float(recentEnergies.count)
        let timeSinceLastBeat = Date().timeIntervalSince(lastBeatTime)

        // Trigger beat when energy spikes well above average, minimum 250ms gap
        if rms > avgEnergy * sensitivity && rms > 0.02 && timeSinceLastBeat > 0.25 {
            lastBeatTime = Date()
            DispatchQueue.main.async { [weak self] in
                self?.onBeat?()
            }
        }
    }
}
