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

    var localParticipant: Participant { room.localParticipant }
    private(set) var agent: Participant?

    private(set) var interactionMode: InteractionMode = .voice

    private(set) var isMicrophoneEnabled = false
    private(set) var isCameraEnabled = false
    private(set) var cameraTrack: (any VideoTrack)?
    private(set) var isScreenShareEnabled = false
    private(set) var screenShareTrack: (any VideoTrack)?

    private(set) var audioDevices: [AudioDevice] = AudioManager.shared.inputDevices
    private(set) var selectedDevice: AudioDevice = AudioManager.shared.inputDevice

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
            }
        }

        Task { @MainActor [weak self] in
            guard let changes = self?.localParticipant.changes else { return }
            for await _ in changes {
                guard let self else { return }

                isMicrophoneEnabled = localParticipant.isMicrophoneEnabled()
                isCameraEnabled = localParticipant.isCameraEnabled()
                cameraTrack = localParticipant.firstCameraVideoTrack
                isScreenShareEnabled = localParticipant.isScreenShareEnabled()
                screenShareTrack = localParticipant.firstScreenShareVideoTrack
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
            try await room.localParticipant.setCamera(enabled: !isCameraEnabled)
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
    }
}
