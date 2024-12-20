import SwiftUI
import LiveKit

struct ConnectButton: View {
    @EnvironmentObject private var tokenService: TokenService
    @EnvironmentObject private var room: Room
    @State private var isConnecting: Bool = false

    var body: some View {
        Button(action: {
            Task {
                if room.connectionState != .disconnected {
                    await room.disconnect()
                } else {
                    isConnecting = true
                    let roomName = "room-\(Int.random(in: 1000 ... 9999))"
                    let participantName = "user-\(Int.random(in: 1000 ... 9999))"

                    do {
                        if let connectionDetails = try await tokenService.fetchConnectionDetails(
                            roomName: roomName,
                            participantName: participantName
                        ) {
                            try await room.connect(url: connectionDetails.serverUrl, token: connectionDetails.participantToken)
                            try await room.localParticipant.setMicrophone(enabled: true)
                        } else {
                            print("Failed to fetch connection details")
                        }
                        isConnecting = false
                    } catch {
                        print("Connection error: \(error)")
                        isConnecting = false
                    }
                }
            }
        }) {
            Text(isConnecting ? "Connecting..." : room.connectionState == .connected ? "Disconnect" : "Start a Conversation")
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(isConnecting)
    }
}
