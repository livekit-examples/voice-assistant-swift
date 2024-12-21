import LiveKit
import LiveKitComponents
import SwiftUI

struct ControlBar: View {
    @EnvironmentObject private var tokenService: TokenService
    @EnvironmentObject private var room: Room
    @State private var isConnecting: Bool = false
    @State private var isDisconnecting: Bool = false
    @Namespace private var animation

    private enum ButtonType {
        case connect, disconnect, transition
    }

    private var buttonType: ButtonType {
        if isConnecting || isDisconnecting {
            .transition
        } else if room.connectionState == .disconnected {
            .connect
        } else {
            .disconnect
        }
    }

    var body: some View {
        HStack(spacing: 16) {
            Spacer()

            switch buttonType {
            case .connect:
                ConnectButton(connectAction: connect)
                    .matchedGeometryEffect(id: "main-button", in: animation, properties: .position)
            case .disconnect:
                HStack(spacing: 2) {
                    Button(action: {
                        Task {
                            try? await room.localParticipant.setMicrophone(
                                enabled: !room.localParticipant.isMicrophoneEnabled())
                        }
                    }) {
                        Label {
                            Text(room.localParticipant.isMicrophoneEnabled() ? "Mute" : "Unmute")
                        } icon: {
                            Image(
                                systemName: room.localParticipant.isMicrophoneEnabled()
                                    ? "mic" : "mic.slash")
                        }
                        .labelStyle(.iconOnly)
                    }
                    .buttonStyle(.plain)
                    .frame(width: 44, height: 44)

                    LocalAudioVisualizer(track: room.localParticipant.firstAudioTrack)
                        .frame(height: 44)
                        .id(room.localParticipant.firstAudioTrack?.id ?? "no-track")  // ensure the component re-renders if the track changes
                }
                .background(.primary.opacity(0.1))
                .cornerRadius(8)
                
                DisconnectButton(disconnectAction: disconnect)
                    .matchedGeometryEffect(id: "main-button", in: animation, properties: .position)
            case .transition:
                TransitionButton(isConnecting: isConnecting)
                    .matchedGeometryEffect(id: "main-button", in: animation, properties: .position)
            }

            Spacer()
        }
        .animation(.spring(duration: 0.3), value: buttonType)
    }

    private func connect() {
        Task {
            isConnecting = true
            let roomName = "room-\(Int.random(in: 1000 ... 9999))"
            let participantName = "user-\(Int.random(in: 1000 ... 9999))"

            do {
                if let connectionDetails = try await tokenService.fetchConnectionDetails(
                    roomName: roomName,
                    participantName: participantName
                ) {
                    try await room.connect(
                        url: connectionDetails.serverUrl, token: connectionDetails.participantToken)
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

    private func disconnect() {
        Task {
            isDisconnecting = true
            await room.disconnect()
            isDisconnecting = false
        }
    }
}

private struct LocalAudioVisualizer: View {
    var track: AudioTrack?

    @StateObject private var audioProcessor: AudioProcessor

    init(track: AudioTrack?) {
        self.track = track
        _audioProcessor = StateObject(
            wrappedValue: AudioProcessor(
                track: track,
                bandCount: 9,
                isCentered: false))
    }

    public var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<9, id: \.self) { index in
                Rectangle()
                    .fill(.primary)
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
                    .scaleEffect(
                        y: max(0.05, CGFloat(audioProcessor.bands[index])), anchor: .center)
            }
        }
        .padding(.leading, 0)
        .padding(.trailing, 16)
    }
}

private struct ConnectButton: View {
    var connectAction: () -> Void

    var body: some View {
        Button(action: connectAction) {
            Text("Start a Conversation")
                .textCase(.uppercase)
        }
        .frame(height: 44)
        .padding(.horizontal, 16)
        .background(
            .primary.opacity(0.1)
        )
        .foregroundStyle(.primary)
        .cornerRadius(8)
    }
}

private struct DisconnectButton: View {
    var disconnectAction: () -> Void

    var body: some View {
        Button(action: disconnectAction) {
            Label {
                Text("Disconnect")
            } icon: {
                Image(systemName: "xmark")
                    .fontWeight(.bold)
            }
            .labelStyle(.iconOnly)
            .frame(width: 44, height: 44)
        }
        .frame(width: 44, height: 44)
        .background(
            .red.opacity(0.9)
        )
        .foregroundStyle(.white)
        .cornerRadius(8)
    }
}

private struct TransitionButton: View {
    var isConnecting: Bool

    var body: some View {
        Button(action: {}) {
            Text(isConnecting ? "Connecting…" : "Disconnecting…")
                .textCase(.uppercase)
        }
        .frame(height: 44)
        .padding(.horizontal, 16)
        .background(
            .primary.opacity(0.1)
        )
        .foregroundStyle(.secondary)
        .cornerRadius(8)
        .disabled(true)
    }
}
