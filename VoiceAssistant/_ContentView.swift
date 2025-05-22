import LiveKitComponents

struct _ContentView: View {
    @StateObject private var room: Room
    @State private var chatViewModel: ChatViewModel

    final class OverrideUIOptions: UIOptions {
        override func noTrackView() -> AnyView {
            AnyView(ProgressView())
        }
    }

    @State private var uiOptions: UIOptions = OverrideUIOptions()

    init() {
        let room = Room()
        _room = StateObject(wrappedValue: room)
        _chatViewModel = State(initialValue: ChatViewModel(room: room, messageReceivers: [TranscriptionStreamReceiver(room: room)]))

        do {
            try AudioManager.shared.setRecordingAlwaysPreparedMode(true)
        } catch {
            print("Failed to prepare recording")
        }
    }

    var body: some View {
        Group {
            if room.connectionState == .disconnected {
                ControlBar()
            } else {
                GeometryReader { geometry in
                    VStack(spacing: 0) {
                        Spacer()
                            .frame(height: max((geometry.size.height - 256 - 64 - 80) / 2, 0))

                        // Agent centered in the middle
                        agent()
                            .frame(maxWidth: geometry.size.width - 32)
                            .padding(.bottom, 32)

                        // Chat takes remaining space with minimum height
                        chat()
                            .frame(height: max((geometry.size.height - 256 - 64 - 32) / 2, 80))

                        // Fixed toolbar at bottom
                        toolbar()
                            .frame(height: 64)
                    }
                }
            }
        }
        .padding()
        .environmentObject(room)
        .environment(\.liveKitUIOptions, uiOptions)
    }

    @ViewBuilder
    private func chat() -> some View {
        ChatView()
            .environment(chatViewModel)
            .overlay(content: tooltip)
    }

    @ViewBuilder
    private func agent() -> some View {
        if let agent = room.agentParticipant {
            ParticipantView(showInformation: false)
                .environmentObject(agent)
        } else {
            Spacer()
        }
    }

    @ViewBuilder
    private func toolbar() -> some View {
        ControlBar()
    }

    @ViewBuilder
    private func tooltip() -> some View {
        if room.agentParticipant?.agentState == .listening, chatViewModel.messages.isEmpty {
            Text("Start talking")
                .font(.system(size: 20))
                .opacity(0.3)
        }
    }
}
