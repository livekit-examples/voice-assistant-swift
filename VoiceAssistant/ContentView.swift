import LiveKit
import SwiftUI
#if os(iOS) || os(macOS)
import LiveKitKrispNoiseFilter
#endif

struct ContentView: View {
    @StateObject private var room = Room()

    // Krisp is available only on iOS and macOS right now
    // Krisp is also a feature of LiveKit Cloud, so if you're using open-source / self-hosted you should remove this
    #if os(iOS) || os(macOS)
    private let krispProcessor = LiveKitKrispNoiseFilter()
    #endif

    init() {
        #if os(iOS) || os(macOS)
        AudioManager.shared.capturePostProcessingDelegate = krispProcessor
        #endif
    }

    var body: some View {
        VStack(spacing: 24) {
            StatusView()
                .frame(height: 256)
                .frame(maxWidth: 512)

            ControlBar()
        }
        .padding()
        .environmentObject(room)
        .onAppear {
            #if os(iOS) || os(macOS)
            room.add(delegate: krispProcessor)
            #endif
        }
    }
}
