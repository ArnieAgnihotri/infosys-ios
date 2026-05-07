import AVFoundation
import Foundation

enum AmbientTrack: String, CaseIterable, Identifiable {
    case rain
    case ocean
    case deepNoise

    var id: String { rawValue }

    var title: String {
        switch self {
        case .rain:
            "Rain"
        case .ocean:
            "Ocean"
        case .deepNoise:
            "Deep noise"
        }
    }

    var symbolName: String {
        switch self {
        case .rain:
            "cloud.rain"
        case .ocean:
            "water.waves"
        case .deepNoise:
            "waveform"
        }
    }

    fileprivate var profile: SoundProfile {
        switch self {
        case .rain:
            SoundProfile(noiseAmount: 0.95, toneAmount: 0.04, toneFrequency: 90, seed: 17)
        case .ocean:
            SoundProfile(noiseAmount: 0.65, toneAmount: 0.22, toneFrequency: 0.18, seed: 29)
        case .deepNoise:
            SoundProfile(noiseAmount: 0.55, toneAmount: 0.28, toneFrequency: 72, seed: 43)
        }
    }
}

private struct SoundProfile {
    let noiseAmount: Double
    let toneAmount: Double
    let toneFrequency: Double
    let seed: UInt64
}

@MainActor
final class AmbientAudioController: ObservableObject {
    @Published var selectedTrack: AmbientTrack = .rain {
        didSet {
            guard selectedTrack != oldValue, isPlaying else { return }
            restart()
        }
    }

    @Published var volume: Float = 0.35 {
        didSet {
            engine.mainMixerNode.outputVolume = volume
        }
    }

    @Published private(set) var isPlaying = false
    @Published private(set) var playbackError: String?

    private let engine = AVAudioEngine()
    private var sourceNode: AVAudioSourceNode?
    private let outputFormat = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 2)

    func setPlaying(_ shouldPlay: Bool) {
        shouldPlay ? play() : stop()
    }

    func play() {
        playbackError = nil
        stopEngineOnly()

        guard let outputFormat else {
            playbackError = "Could not prepare audio."
            return
        }

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)

            let node = makeSourceNode(for: selectedTrack)
            sourceNode = node
            engine.attach(node)
            engine.connect(node, to: engine.mainMixerNode, format: outputFormat)
            engine.mainMixerNode.outputVolume = volume
            try engine.start()
            isPlaying = true
        } catch {
            playbackError = "Audio could not start on this device."
            stopEngineOnly()
        }
    }

    func stop() {
        stopEngineOnly()
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    private func restart() {
        play()
    }

    private func stopEngineOnly() {
        if engine.isRunning {
            engine.stop()
        }

        if let sourceNode {
            engine.detach(sourceNode)
        }

        sourceNode = nil
        isPlaying = false
    }

    private func makeSourceNode(for track: AmbientTrack) -> AVAudioSourceNode {
        let profile = track.profile
        let sampleRate = 44_100.0
        let twoPi = 2.0 * Double.pi

        var phase = 0.0
        var slowPhase = 0.0
        var seed = profile.seed
        var filteredNoise = 0.0

        return AVAudioSourceNode { _, _, frameCount, audioBufferList -> OSStatus in
            let buffers = UnsafeMutableAudioBufferListPointer(audioBufferList)

            for frame in 0..<Int(frameCount) {
                seed = seed &* 2_862_933_555_777_941_757 &+ 3_037_000_493
                let whiteNoise = (Double(seed & 0xffff) / 32_768.0) - 1.0

                filteredNoise = (filteredNoise * 0.86) + (whiteNoise * 0.14)
                phase += profile.toneFrequency / sampleRate
                slowPhase += 0.08 / sampleRate

                if phase >= 1 { phase -= 1 }
                if slowPhase >= 1 { slowPhase -= 1 }

                let swell = 0.68 + (sin(twoPi * slowPhase) * 0.24)
                let tone = sin(twoPi * phase) * profile.toneAmount
                let mixed = ((filteredNoise * profile.noiseAmount) + tone) * swell
                let sample = Float(max(-0.18, min(0.18, mixed)))

                for buffer in buffers {
                    let pointer = buffer.mData?.assumingMemoryBound(to: Float.self)
                    pointer?[frame] = sample
                }
            }

            return noErr
        }
    }

    deinit {
        engine.stop()
    }
}
