import SwiftUI
import LiveKit
import LiveKitComponents

struct ControlBar: View {
    @EnvironmentObject private var tokenService: TokenService
    @EnvironmentObject private var room: Room
    @State private var isConnecting: Bool = false
    @State private var showingMicrophonePicker: Bool = false

    var body: some View {
        HStack(spacing: 16) {
            Spacer()

            if room.connectionState == .connected {
                HStack(spacing: 0) {
                    HStack(spacing: 2) {
                        Button(action: {
                            Task {
                                try? await room.localParticipant.setMicrophone(enabled: !room.localParticipant.isMicrophoneEnabled())
                            }
                        }) {
                            Label {
                                Text(room.localParticipant.isMicrophoneEnabled() ? "Mute" : "Unmute")
                            } icon: {
                                Image(systemName: room.localParticipant.isMicrophoneEnabled() ? "mic" : "mic.slash")
                            }
                            .labelStyle(.iconOnly)
                        }
                        .buttonStyle(.plain)
                        .frame(width: 44, height: 44)

                        LocalAudioVisualizer(track: room.localParticipant.firstAudioTrack)
                            .frame(height: 44)
                            .id(room.localParticipant.firstAudioTrack?.id ?? "no-track") // ensure the component re-renders if the track changes
                    }
                    .background(.primary.opacity(0.1))

                    Button(action: {
                        showingMicrophonePicker.toggle()
                    }) {
                        Image(systemName: "chevron.down")
                    }
                    .buttonStyle(.plain)
                    .frame(width: 44, height: 44)
                    .popover(isPresented: $showingMicrophonePicker) {
                        VStack(alignment: .leading) {
                            Text("Select Microphone")
                                .font(.headline)
                                .padding()
                            // Add your microphone list here
                        }
                        .frame(minWidth: 300)
                    }
                }.background(.primary.opacity(0.1))
                    .cornerRadius(8)
            }

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
                if room.connectionState == .connected {
                    Label {
                        Text("Disconnect")
                    } icon: {
                        Image(systemName: "xmark")
                    }
                    .labelStyle(.iconOnly)
                } else {
                    if isConnecting {
                        Text("Connecting…")
                    } else {
                        Text("Start a Conversation")
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(isConnecting)

            Spacer()
        }
    }
}

private struct LocalAudioVisualizer: View {
    var track: AudioTrack?

    @StateObject private var audioProcessor: AudioProcessor;


    init(track: AudioTrack?) {
        self.track = track
        _audioProcessor = StateObject(wrappedValue: AudioProcessor(track: track,
                                                                   bandCount: 9,
                                                                   isCentered: false))
    }

    public var body: some View {
        HStack(spacing: 3) {
            ForEach(0 ..< 9, id: \.self) { index in
                Rectangle()
                    .fill(.primary)
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
                    .scaleEffect(y: max(0.05, CGFloat(audioProcessor.bands[index])), anchor: .center)
            }
        }
        .padding(.leading, 0)
        .padding(.trailing, 16)
    }
}
