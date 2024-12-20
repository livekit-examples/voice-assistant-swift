import LiveKit
import LiveKitComponents
import SwiftUI

struct ContentView: View {
    @State private var isConnecting: Bool = false
    @State private var connectionDetails: ConnectionDetails? = nil

    var body: some View {
        VStack(spacing: 24) {
            if let connectionDetails {
                RoomScope(
                    url: connectionDetails.serverUrl,
                    token: connectionDetails.participantToken,
                    connect: true,
                    enableCamera: false,
                    enableMicrophone: true
                ) {
                    Text("Connected")
                }
            } else {

                Text(
                    "Test"
                )
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

                ConnectButton(connectionDetails: $connectionDetails)
            }
        }
        .padding()
    }
    //    }
}

private struct ConnectButton: View {
    @EnvironmentObject private var tokenService: TokenService
    @State private var isConnecting: Bool = false
    @Binding var connectionDetails: ConnectionDetails?

    var body: some View {
        Button(action: {
            isConnecting = true
            Task {
                let roomName = "room-\(Int.random(in: 1000 ... 9999))"
                let participantName = "user-\(Int.random(in: 1000 ... 9999))"

                do {
                    self.connectionDetails = try await tokenService.fetchConnectionDetails(
                        roomName: roomName,
                        participantName: participantName
                    )
                } catch {
                    print("Connection error: \(error)")
                    isConnecting = false
                }
            }
        }) {
            Text(isConnecting ? "Connecting..." : "Start a Conversation")
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(isConnecting)
    }
}
