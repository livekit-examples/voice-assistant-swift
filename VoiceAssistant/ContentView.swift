import LiveKit
import SwiftUI
#if os(iOS) || os(macOS)
import LiveKitKrispNoiseFilter
#endif

struct ContentView: View {
    @StateObject private var room = Room()
    
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
