import LiveKit
import SwiftUI

struct ContentView: View {
    @StateObject private var room = Room()

    var body: some View {
        VStack(spacing: 24) {
            StatusView()
                .frame(height: 256)

            ControlBar()
        }
        .padding()
        .environmentObject(room)
        .environmentObject(room.localParticipant)
    }
}
