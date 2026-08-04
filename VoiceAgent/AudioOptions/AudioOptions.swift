import Combine
import LiveKit
import SwiftUI

/// Selects which implementation handles microphone voice processing
/// (echo cancellation, noise suppression, and auto gain control).
enum VoiceProcessingMode: CaseIterable, Identifiable {
    /// Prefer Apple voice processing when available and fall back to
    /// WebRTC software processing. This is the SDK default.
    case automatic
    /// Use Apple voice processing only. Applying fails when it is not available.
    case platform
    /// Use WebRTC software processing. Turns off Apple voice processing
    /// for the microphone.
    case software

    var id: Self {
        self
    }
}

/// Stores the selected audio options and applies them to the local microphone.
///
/// A selection made before connecting is applied as soon as the microphone
/// track is created, so it takes effect when the microphone is published.
/// Changing the selection during a call updates the live track.
///
/// To guarantee that the very first captured frames already use custom
/// processing options, pass them as room defaults instead. See the comment
/// on `RoomOptions` in `VoiceAgentApp`.
final class AudioOptions: ObservableObject {
    @Published private(set) var voiceProcessingMode: VoiceProcessingMode = .automatic

    /// The last error from applying the selection, if any.
    @Published private(set) var applyError: Swift.Error?

    private let localMedia: LocalMedia
    private var cancellable: AnyCancellable?

    init(localMedia: LocalMedia) {
        self.localMedia = localMedia
        // Apply the stored selection whenever a new microphone track appears,
        // e.g. when pre-connect audio starts capturing.
        cancellable = localMedia.$microphoneTrack
            .map { $0 as? LocalAudioTrack }
            .removeDuplicates { $0 === $1 }
            .compactMap(\.self)
            .sink { [weak self] track in
                guard let self, voiceProcessingMode != .automatic else { return }
                apply(to: track)
            }
    }

    /// The selected mode as SDK processing options.
    /// All processing components stay enabled, only the implementation changes.
    var processingOptions: AudioProcessingOptions {
        switch voiceProcessingMode {
        case .automatic:
            AudioProcessingOptions()
        case .platform:
            AudioProcessingOptions(
                echoCancellationMode: .platform,
                autoGainControlMode: .platform,
                noiseSuppressionMode: .platform
            )
        case .software:
            AudioProcessingOptions(
                echoCancellation: true,
                autoGainControl: true,
                noiseSuppression: true,
                highpassFilter: false,
                echoCancellationMode: .software,
                autoGainControlMode: .software,
                noiseSuppressionMode: .software
            )
        }
    }

    /// Applies the given mode to the local microphone.
    /// Without a track the selection is stored and applied on the next publish.
    func apply(_ mode: VoiceProcessingMode) {
        voiceProcessingMode = mode
        applyError = nil
        guard let track = localMedia.microphoneTrack as? LocalAudioTrack else { return }
        apply(to: track)
    }

    private func apply(to track: LocalAudioTrack) {
        do {
            try track.setAudioProcessingOptions(processingOptions)
            applyError = nil
        } catch {
            applyError = error
        }
    }
}
