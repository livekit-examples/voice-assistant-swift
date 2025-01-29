import SwiftUI
import LiveKit

@main
struct VoiceAssistantApp: App {
    private var tokenService: TokenService = .init()

    init() {
        LiveKitSDK.setLoggerStandardOutput()
        AudioManager.shared.isRecordingAlwaysPrepared = true
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(tokenService)
        }
    }
}
