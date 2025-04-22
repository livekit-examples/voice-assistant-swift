@preconcurrency import LiveKit
import SwiftUI
#if os(iOS) || os(macOS)
import LiveKitKrispNoiseFilter
#endif

struct ContentView: View {
    @StateObject private var room: Room
    @State private var chatViewModel: ChatViewModel

    // Krisp is available only on iOS and macOS right now
    // Krisp is also a feature of LiveKit Cloud, so if you're using open-source / self-hosted you should remove this
    #if os(iOS) || os(macOS)
    private let krispProcessor = LiveKitKrispNoiseFilter()
    #endif

    init() {
        #if os(iOS) || os(macOS)
        AudioManager.shared.capturePostProcessingDelegate = krispProcessor
        #endif
        let room = Room()
        _room = StateObject(wrappedValue: room)
        _chatViewModel = State(initialValue: ChatViewModel(room: room, messageReceivers: TranscriptionStreamReceiver(room: room)))
    }

    var body: some View {
        Group {
            if room.connectionState == .disconnected {
                ControlBar()
            } else {
                GeometryReader { geometry in
                    VStack(spacing: 0) {
                        // Top spacer to push content down
                        Spacer()
                            .frame(height: max((geometry.size.height - 256 - 64 - 80) / 2, 0))
                        
                        // Agent centered in the middle
                        agent()
                        
                        // Chat takes remaining space with minimum height
                        chat()
                            .frame(height: max((geometry.size.height - 256 - 64) / 2, 80))
                        
                        // Fixed toolbar at bottom
                        toolbar()
                    }
                }
            }
        }
        .padding()
        .environmentObject(room)
        .onAppear {
            #if os(iOS) || os(macOS)
            room.add(delegate: krispProcessor)
            #endif
        }
    }

    @ViewBuilder
    private func chat() -> some View {
        ChatView()
            .environment(chatViewModel)
            .overlay(content: tooltip)
    }

    @ViewBuilder
    private func agent() -> some View {
        if let participant = room.agentParticipant {
            AgentView()
                .frame(width: 256, height: 256)
                .environmentObject(participant as Participant)
        } else {
            Rectangle()
                .fill(.clear)
                .frame(width: 256, height: 256)
        }
    }

    @ViewBuilder
    private func toolbar() -> some View {
        ControlBar()
            .frame(height: 64)
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
