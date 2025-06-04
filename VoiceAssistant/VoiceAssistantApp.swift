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
        #if os(visionOS)
        .windowStyle(.plain)
        .windowResizability(.contentMinSize)
        .defaultSize(width: 1500, height: 500)
        #endif
    }
}

struct AgentFeatures: OptionSet {
    let rawValue: Int

    static let voice = Self(rawValue: 1 << 0)
    static let text = Self(rawValue: 1 << 1)
    static let video = Self(rawValue: 1 << 2)

//    static let defaults: Self = [.voice, .text]
    static let defaults: Self = [.voice, .text, .video]
}
