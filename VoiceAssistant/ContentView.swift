import LiveKit
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
        _chatViewModel = State(initialValue: ChatViewModel(messageProviders: TranscriptionMessageProvider(room: room)))
    }

    var body: some View {
        VStack(spacing: 24) {
            StatusView()
                .frame(height: 256)
                .frame(maxWidth: 512)

            ControlBar()
            ChatView()
                .environment(chatViewModel)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding()
        .environmentObject(room)
        .onAppear {
            #if os(iOS) || os(macOS)
            room.add(delegate: krispProcessor)
            #endif
        }
        .ignoresSafeArea()
    }
}
