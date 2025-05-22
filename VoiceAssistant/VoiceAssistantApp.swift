import LiveKit
import SwiftUI

@main
struct VoiceAssistantApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(AppViewModel())
        }
    }
}
