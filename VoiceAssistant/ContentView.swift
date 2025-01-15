import LiveKit
import SwiftUI

struct ContentView: View {
    @StateObject private var room = Room()
    @State private var isUserMutedTalking: Bool = false

    var body: some View {
        VStack(spacing: 24) {
            Text(isUserMutedTalking ? "Are you talking? Your mic is muted" : "")
            StatusView()
                .frame(height: 256)
                .frame(maxWidth: 512)
            
            ControlBar()
        }
        .padding()
        .environmentObject(room)
        .onAppear {
            AudioManager.shared.prepareRecording()
            
            AudioManager.shared.onMutedSpeechActivityEvent = { _, event in
                DispatchQueue.main.async {
                    isUserMutedTalking = event == .started
                }
            }
        }
    }
}
