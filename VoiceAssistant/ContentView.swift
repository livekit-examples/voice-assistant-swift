import SwiftUI
import LiveKit
import LiveKitComponents

struct ContentView: View {
//    @State private var isConnecting: Bool = false
    private var tokenService: TokenService = .init()
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

                Button(action: {
                    Task {
//                        isConnecting = true

                        let roomName = "room-\(Int.random(in: 1000 ... 9999))"
                        let participantName = "user-\(Int.random(in: 1000 ... 9999))"

                        do {
                            self.connectionDetails = try await tokenService.fetchConnectionDetails(
                                roomName: roomName,
                                participantName: participantName
                            )
                        } catch {
                            print("Connection error: \(error)")
                        }
//                        isConnecting = false
                    }
                }) {
                    Text("Start a Conversation")
                        .font(.headline)
                        .frame(maxWidth: 280)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
//                .disabled(isConnecting)
            }
        }
        .padding()
    }
    //    }
}
