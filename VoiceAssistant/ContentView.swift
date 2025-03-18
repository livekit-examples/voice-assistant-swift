import AVFAudio
import LiveKit
import SwiftUI
#if os(iOS) || os(macOS)
import LiveKitKrispNoiseFilter
#endif

struct ContentView: View {
    @StateObject private var room = Room()

    // Krisp is available only on iOS and macOS right now
    // Krisp is also a feature of LiveKit Cloud, so if you're using open-source / self-hosted you should remove this
    #if os(iOS) || os(macOS)
    private let krispProcessor = LiveKitKrispNoiseFilter()
    #endif

    init() {
        #if os(iOS) || os(macOS)
        AudioManager.shared.capturePostProcessingDelegate = krispProcessor
        #endif
    }

    var body: some View {
        VStack(spacing: 24) {
            StatusView()
                .frame(height: 256)
                .frame(maxWidth: 512)

            ControlBar()
            DebugBar()
        }
        .padding()
        .environmentObject(room)
        .onAppear {
            #if os(iOS) || os(macOS)
            room.add(delegate: krispProcessor)
            #endif
        }
    }
}

extension AudioDuckingLevel: @retroactive Identifiable {
    public var id: Int {
        rawValue
    }
}

extension AudioDuckingLevel: @retroactive CustomStringConvertible {
    public var description: String {
        switch self {
        case .default:
            return "Default"
        case .min:
            return "Min"
        case .mid:
            return "Mid"
        case .max:
            return "Max"
        @unknown default:
            return "Unknown"
        }
    }
}

struct DebugBar: View {
    enum MusicPlayerState {
        case stopped
        case downloading
        case playing
    }

    @State var musicPlayerState: MusicPlayerState = .stopped

    @State var isVoiceProcessingEnabled: Bool = true
    @State var isVoiceProcessingBypassed: Bool = false
    @State var isRecordingAlwaysPrepared: Bool = false

    let duckingLevels: [AudioDuckingLevel] = [
        .default,
        .min,
        .mid,
        .max,
    ]
    @State var otherAudioDuckingLevel: AudioDuckingLevel = .default

    @State private var player: AVAudioPlayer?
    @State private var localMusicFile: URL?

    var body: some View {
        AudioSessionMonitorView()

        Toggle(isOn: $isVoiceProcessingEnabled) {
            Text("Voice processing enabled")
        }.onChange(of: isVoiceProcessingEnabled) { _, _ in
            print("Setting voice processing enabled: \(isVoiceProcessingEnabled)")
            Task {
                do {
                    try AudioManager.shared.setVoiceProcessingEnabled(isVoiceProcessingEnabled)
                } catch {
                    print("Failed to set voice processing enabled: \(error)")
                }
            }
        }

        Toggle(isOn: $isVoiceProcessingBypassed) {
            Text("Voice processing bypassed")
        }.onChange(of: isVoiceProcessingBypassed) { _, _ in
            print("Setting voice processing bypassed: \(isVoiceProcessingBypassed)")
            AudioManager.shared.isVoiceProcessingBypassed = isVoiceProcessingBypassed
        }

        Picker("Audio Ducking Level", selection: $otherAudioDuckingLevel) {
            ForEach(duckingLevels, id: \.self) { option in
                Text(String(describing: option))
                    .tag(option)
            }
        }
        .onChange(of: otherAudioDuckingLevel) { _, newValue in
            print("Setting other audio ducking level: \(newValue)")
            AudioManager.shared.duckingLevel = newValue
        }

        // Prepare recording switch
        Toggle(isOn: $isRecordingAlwaysPrepared) {
            Text("Recording prepared")
        }.onChange(of: isRecordingAlwaysPrepared) { _, _ in
            print("Setting recording always prepared mode: \(isRecordingAlwaysPrepared)")
            Task {
                do {
                    try AudioManager.shared.setRecordingAlwaysPreparedMode(isRecordingAlwaysPrepared)
                } catch {
                    print("Failed to set recording always prepared mode: \(error)")
                }
            }
        }

        // BG Music player
        if musicPlayerState == .stopped {
            Button {
                Task {
                    do {
                        if localMusicFile == nil {
                            musicPlayerState = .downloading
                            print("Downloading music file...")
                            let url = URL(string: "https://upload.wikimedia.org/wikipedia/commons/b/b0/Free_Man_-_Wild_Blue_Country_-_United_States_Air_Force_Academy_Band.mp3")!
                            let (localUrl, _) = try await URLSession.shared.download(from: url)
                            localMusicFile = localUrl
                        }
                        guard let localMusicFile else { return }
                        print("Playing music file...")
                        let player = try AVAudioPlayer(contentsOf: localMusicFile)
                        player.volume = 1.0
                        player.play()

                        // Low volume workaround
                        // https://developer.apple.com/forums/thread/721535
                        try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
                        try AVAudioSession.sharedInstance().overrideOutputAudioPort(.none)

                        musicPlayerState = .playing
                        self.player = player
                    } catch {
                        print("Failed to play music file: \(error)")
                    }
                }
            } label: {
                Text("Play Music")
            }
        } else if musicPlayerState == .downloading {
            HStack {
                ProgressView()
                Text("Downloading...")
            }
        } else if musicPlayerState == .playing {
            Button {
                player?.stop()
                player = nil
                musicPlayerState = .stopped
            } label: {
                Text("Stop Music")
            }
        }
    }
}
