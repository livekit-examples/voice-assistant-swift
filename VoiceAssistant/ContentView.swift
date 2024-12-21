import LiveKit
import SwiftUI
import LiveKitKrispNoiseFilter

struct ContentView: View {
    @StateObject private var room = Room()

    private let krispProcessor = LiveKitKrispNoiseFilter()

    init() {
        AudioManager.shared.capturePostProcessingDelegate = krispProcessor
    }

    var body: some View {
        VStack(spacing: 24) {
            StatusView()
                .frame(height: 256)

            ControlBar()
        }
        .padding()
        .environmentObject(room)
    }
}
