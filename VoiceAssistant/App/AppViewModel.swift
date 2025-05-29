@preconcurrency import AVFoundation
import Combine
import LiveKit
import Observation

@MainActor
@Observable
final class AppViewModel {
    enum InteractionMode {
        case voice
        case text
    }

    private(set) var connectionState: ConnectionState = .disconnected
    private(set) var isListening = false

    private(set) var agent: Participant?

    private(set) var interactionMode: InteractionMode = .voice

    private(set) var isMicrophoneEnabled = false
    private(set) var audioTrack: (any AudioTrack)?
    private(set) var isCameraEnabled = false
    private(set) var cameraTrack: (any VideoTrack)?
    private(set) var isScreenShareEnabled = false
    private(set) var screenShareTrack: (any VideoTrack)?

    private(set) var agentAudioTrack: (any AudioTrack)?
    private(set) var avatarCameraTrack: (any VideoTrack)?

    private(set) var audioDevices: [AudioDevice] = AudioManager.shared.inputDevices
    private(set) var selectedDevice: AudioDevice = AudioManager.shared.inputDevice

    private(set) var videoDevices: [AVCaptureDevice] = []
    private(set) var selectedVideoDevice: AVCaptureDevice?

    private(set) var canSwitchCamera = false

    @ObservationIgnored
    @Dependency(\.room) private var room
    @ObservationIgnored
    @Dependency(\.tokenService) private var tokenService
    @ObservationIgnored
    @Dependency(\.errorHandler) private var errorHandler

    init() {
        Task { @MainActor [weak self] in
            guard let changes = self?.room.changes else { return }
            for await _ in changes {
                guard let self else { return }

                connectionState = room.connectionState
                agent = room.agentParticipant

                isMicrophoneEnabled = room.localParticipant.isMicrophoneEnabled()
                audioTrack = room.localParticipant.firstAudioTrack
                isCameraEnabled = room.localParticipant.isCameraEnabled()
                cameraTrack = room.localParticipant.firstCameraVideoTrack
                isScreenShareEnabled = room.localParticipant.isScreenShareEnabled()
                screenShareTrack = room.localParticipant.firstScreenShareVideoTrack

                agentAudioTrack = room.agentParticipant?.firstAudioTrack
                avatarCameraTrack = room.agentParticipant?.avatarWorker?.firstCameraVideoTrack
            }
        }

        do {
            try AudioManager.shared.setRecordingAlwaysPreparedMode(true)
        } catch {
            errorHandler(error)
        }
        AudioManager.shared.onDeviceUpdate = { _ in
            Task { @MainActor in
                self.audioDevices = AudioManager.shared.inputDevices
                self.selectedDevice = AudioManager.shared.inputDevice
            }
        }

        Task { @MainActor in
            canSwitchCamera = try await CameraCapturer.canSwitchPosition()
            videoDevices = try await CameraCapturer.captureDevices()
            selectedVideoDevice = videoDevices.first
        }
    }

    deinit {
        AudioManager.shared.onDeviceUpdate = nil
    }

    private func resetState() {
        isListening = false
        interactionMode = .voice
    }

    func connect() async {
        resetState()
        do {
            try await room.withPreConnectAudio {
                await MainActor.run { self.isListening = true }

                let connectionDetails = try await self.getConnection()

                try await self.room.connect(
                    url: connectionDetails.serverUrl,
                    token: connectionDetails.participantToken,
                    connectOptions: .init(enableMicrophone: true)
                )
            }
        } catch {
            errorHandler(error)
            resetState()
        }
    }

    func disconnect() async {
        await room.disconnect()
        resetState()
    }

    private func getConnection() async throws -> ConnectionDetails {
        let roomName = "room-\(Int.random(in: 1000 ... 9999))"
        let participantName = "user-\(Int.random(in: 1000 ... 9999))"

        return try await tokenService.fetchConnectionDetails(
            roomName: roomName,
            participantName: participantName
        )!
    }

    func enterTextInputMode() {
        switch interactionMode {
        case .voice:
            interactionMode = .text
        case .text:
            interactionMode = .voice
        }
    }

    func toggleMicrophone() async {
        do {
            try await room.localParticipant.setMicrophone(enabled: !isMicrophoneEnabled)
        } catch {
            errorHandler(error)
        }
    }

    func toggleCamera() async {
        do {
            try await room.localParticipant.setCamera(enabled: !isCameraEnabled, captureOptions: CameraCaptureOptions(device: selectedVideoDevice))
        } catch {
            errorHandler(error)
        }
    }

    func toggleScreenShare() async {
        do {
            try await room.localParticipant.setScreenShare(enabled: !isScreenShareEnabled)
        } catch {
            errorHandler(error)
        }
    }

    func select(audioDevice: AudioDevice) {
        selectedDevice = audioDevice

        AudioManager.shared.inputDevice = audioDevice
    }

    func select(videoDevice: AVCaptureDevice) async {
        selectedVideoDevice = videoDevice

        guard let cameraTrack = cameraTrack as? LocalVideoTrack,
              let cameraCapturer = cameraTrack.capturer as? CameraCapturer else { return }

        do {
            let captureOptions = CameraCaptureOptions(device: videoDevice)
            try await cameraCapturer.set(options: captureOptions)
        } catch {
            errorHandler(error)
        }
    }

    func switchCamera() async {
        guard let cameraTrack = cameraTrack as? LocalVideoTrack,
              let cameraCapturer = cameraTrack.capturer as? CameraCapturer else { return }
        do {
            try await cameraCapturer.switchCameraPosition()
        } catch {
            errorHandler(error)
        }
    }
}
