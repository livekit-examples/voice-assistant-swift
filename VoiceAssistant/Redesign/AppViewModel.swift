import LiveKit
import Observation

@MainActor
@Observable
final class AppViewModel {
    enum InputMode {
        case voice
        case text
    }

    struct State {
        var connectionState: ConnectionState = .disconnected
        var isListening = false
        var error: Error?

        var agent: Participant?

        var inputMode: InputMode = .voice
    }

    private(set) var state = State()

    @ObservationIgnored
    @Dependency(\.room) private var room
    @ObservationIgnored
    @Dependency(\.tokenService) private var tokenService

    init() {
        room.add(delegate: self)
    }

    deinit {
        // TODO: Fixme
        //        room.remove(delegate: self)
    }

    func connect() {
        state.error = nil
        state.isListening = false
        Task {
            do {
                try await room.withPreConnectAudio {
                    await MainActor.run { self.state.isListening = true }

                    let connectionDetails = try await self.getConnection()

                    try await self.room.connect(
                        url: connectionDetails.serverUrl,
                        token: connectionDetails.participantToken,
                        connectOptions: .init(enableMicrophone: true)
                    )
                }
            } catch {
                state.error = error
                state.isListening = false
            }
        }
    }

    func disconnect() {
        Task {
            await room.disconnect()
        }
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
        state.inputMode = .text
    }
}

extension AppViewModel: RoomDelegate {
    nonisolated func room(_: Room, didUpdateConnectionState connectionState: ConnectionState, from _: ConnectionState) {
        Task { @MainActor in
            state.connectionState = connectionState
        }
    }

    nonisolated func room(_: Room, participantDidConnect participant: RemoteParticipant) {
        Task { @MainActor in
            if participant.isAgent {
                state.agent = participant
            }
        }
    }

    nonisolated func room(_: Room, participantDidDisconnect participant: RemoteParticipant) {
        Task { @MainActor in
            if participant.isAgent {
                state.agent = nil
            }
        }
    }
}
