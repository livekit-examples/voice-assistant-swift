import LiveKit
import LiveKitComponents
import SwiftUI

struct ContentView: View {
    @State private var isConnecting: Bool = false
    @StateObject private var room = Room()

    private var statusText: String {
        if room.connectionState == .connected {
            return agentParticipant?.agentState.description ?? "Waiting for agent"
        } else {
            switch room.connectionState {
            case .disconnected:
                return "Disconnected"
            case .connecting:
                return "Connecting"
            case .reconnecting:
                return "Reconnecting"
            case .connected:
                return "Connected"
            }
        }

    }

    private var agentParticipant: RemoteParticipant? {
        for participant in room.remoteParticipants.values {
            if participant.kind == .agent {
                return participant
            }
        }

        return nil
    }

    var body: some View {
        VStack(spacing: 24) {
            Text(statusText)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            ConnectButton()
        }
        .padding()
        .environmentObject(room)
    }
}

private struct ConnectButton: View {
    @EnvironmentObject private var tokenService: TokenService
    @EnvironmentObject var room: Room
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
