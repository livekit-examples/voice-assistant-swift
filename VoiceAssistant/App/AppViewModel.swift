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
    var localParticipant: Participant { room.localParticipant }

    private(set) var interactionMode: InteractionMode = .voice

    private(set) var isMuted = false
    private(set) var isVideoEnabled = false
    private(set) var video: TrackPublication?

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
                agent = room.remoteParticipants.values.first { $0.isAgent }
                video = localParticipant.firstCameraPublication
            }
        }

        try? AudioManager.shared.setRecordingAlwaysPreparedMode(true)
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
        isMuted = false
        isVideoEnabled = false
        video = nil
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
            isListening = false
        }
    }

    func disconnect() async {
        await room.disconnect()
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

    func toggleMute() async {
        isMuted.toggle()
        do {
            try await room.localParticipant.setMicrophone(enabled: !isMuted)
        } catch {}
    }

    func toggleVideo() async {
        isVideoEnabled.toggle()
        do {
            try await room.localParticipant.setCamera(enabled: isVideoEnabled)
        } catch {}
    }

    func select(audioDevice: AudioDevice) {
        selectedDevice = audioDevice
    }
}
