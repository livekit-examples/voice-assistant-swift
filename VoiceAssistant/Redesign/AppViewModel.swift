import LiveKit
import Observation

@MainActor
@Observable
final class AppViewModel {
    struct State {
        var connectionState: ConnectionState = .disconnected
        var isListening = false
        var error: Error?
    }

    var state: State = .init()

    @ObservationIgnored
    let room: Room
    @ObservationIgnored
    private let tokenService: TokenService

    init(room: Room = Room(), tokenService: TokenService = TokenService()) {
        self.room = room
        self.tokenService = tokenService

        room.add(delegate: self)
    }

    deinit {
        room.remove(delegate: self)
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
}

extension AppViewModel: RoomDelegate {
    nonisolated func room(_: Room, didUpdateConnectionState connectionState: ConnectionState, from _: ConnectionState) {
        Task { @MainActor in
            state.connectionState = connectionState
        }
    }
}
