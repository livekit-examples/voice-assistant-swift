import LiveKit
import SwiftUI

@main
struct VoiceAssistantApp: App {
    private let viewModel = AppViewModel()

    var body: some Scene {
        WindowGroup {
            AppView()
                .environment(viewModel)
        }
    }
}
