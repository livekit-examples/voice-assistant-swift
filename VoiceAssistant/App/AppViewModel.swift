import LiveKit
import Observation

@MainActor
@Observable
final class AppViewModel {
    enum InputMode {
        case voice
        case text
    }

    private(set) var connectionState: ConnectionState = .disconnected
    private(set) var isListening = false
    private(set) var error: Error?

    private(set) var agent: Participant?
    var localParticipant: Participant { room.localParticipant }

    private(set) var inputMode: InputMode = .voice

    private(set) var isMuted = false
    private(set) var isVideoEnabled = false
    private(set) var video: TrackPublication?

    private(set) var audioDevices: [AudioDevice] = AudioManager.shared.inputDevices
    private(set) var selectedDevice: AudioDevice = AudioManager.shared.inputDevice

    @ObservationIgnored
    @Dependency(\.room) private var room
    @ObservationIgnored
    @Dependency(\.tokenService) private var tokenService

    init() {
        room.add(delegate: self)

        try? AudioManager.shared.setRecordingAlwaysPreparedMode(true)
        AudioManager.shared.onDeviceUpdate = { _ in
            Task { @MainActor in
                self.audioDevices = AudioManager.shared.inputDevices
                self.selectedDevice = AudioManager.shared.inputDevice
            }
        }
    }

    deinit {
        // TODO: Fixme
        //        room.remove(delegate: self)
        AudioManager.shared.onDeviceUpdate = nil
    }

    private func resetState() {
        error = nil
        isListening = false
        inputMode = .voice
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
            self.error = error
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
        switch inputMode {
        case .voice:
            inputMode = .text
        case .text:
            inputMode = .voice
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

extension AppViewModel: RoomDelegate {
    nonisolated func room(_: Room, didUpdateConnectionState connectionState: ConnectionState, from _: ConnectionState) {
        Task { @MainActor in
            self.connectionState = connectionState
        }
    }

    nonisolated func room(_: Room, participant _: LocalParticipant, didPublishTrack publication: LocalTrackPublication) {
        Task { @MainActor in
            if publication.source == .camera, !publication.isMuted {
                video = publication
            }
        }
    }

    nonisolated func room(_: Room, participant _: LocalParticipant, didUnpublishTrack publication: LocalTrackPublication) {
        Task { @MainActor in
            if publication.source == .camera {
                video = nil
            }
        }
    }

    nonisolated func room(_: Room, participantDidConnect participant: RemoteParticipant) {
        Task { @MainActor in
            if participant.isAgent {
                agent = participant
            }
        }
    }

    nonisolated func room(_: Room, participantDidDisconnect participant: RemoteParticipant) {
        Task { @MainActor in
            if participant.isAgent {
                agent = nil
            }
        }
    }
}
