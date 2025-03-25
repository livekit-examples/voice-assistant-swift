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
        _chatViewModel = State(initialValue: ChatViewModel(room: room, messageReceivers: TranscriptionReceiver(room: room)))
    }

    var body: some View {
        Group {
            if room.connectionState == .disconnected {
                ControlBar()
            } else {
                VStack {
                    ChatView()
                        .environment(chatViewModel)
                    HStack(alignment: .center) {
                        StatusView()
                            .frame(width: 58)
                        Spacer()
                            .frame(maxWidth: .infinity)
                        ControlBar()
                            .layoutPriority(1)
                    }
                    .frame(height: 64)
                }
                .overlay(content: tooltip)
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
    private func tooltip() -> some View {
        if room.agentState == .listening, chatViewModel.messages.isEmpty {
            Text("Start talking")
                .font(.system(size: 20))
                .opacity(0.3)
        }
    }
}
