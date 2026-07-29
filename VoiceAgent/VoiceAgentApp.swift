import LiveKit
import SwiftUI

/// Fetches connection details from a custom backend token endpoint.
/// The `EndpointTokenSource` protocol provides the POST request and
/// JSON encoding/decoding; only the URL needs to be supplied.
struct TokenSourceEndpoint: EndpointTokenSource {
    let url: URL
}

@main
struct VoiceAgentApp: App {
    /// To use the LiveKit Cloud sandbox (development only):
    /// - Enable the token server from your project's Options on the
    ///   Settings page: https://cloud.livekit.io/projects/p_/settings/project
    /// - Create a .env.xcconfig file with your LIVEKIT_SANDBOX_ID
    private static let sandboxID = Bundle.main.object(
        forInfoDictionaryKey: "LiveKitSandboxId"
    ) as? String ?? ""

    /// For development, switch back to the sandbox with
    /// `SandboxTokenSource(id: Self.sandboxID).cached()`.
    private let session = Session(
        tokenSource: TokenSourceEndpoint(url: URL(string: "https://livekit.com/api/homepage-agent/token")!).cached(),
        options: SessionOptions(room: Room(roomOptions: RoomOptions(
            defaultScreenShareCaptureOptions: ScreenShareCaptureOptions(useBroadcastExtension: true)
        )))
    )

    var body: some Scene {
        WindowGroup {
            AppView()
                .environmentObject(session)
                .environmentObject(LocalMedia(session: session))
                .environment(\.voiceEnabled, true)
                .environment(\.videoEnabled, true)
                .environment(\.textEnabled, true)
        }
        #if os(macOS)
        .defaultSize(width: 900, height: 900)
        #endif
        #if os(visionOS)
        .windowStyle(.plain)
        .windowResizability(.contentMinSize)
        .defaultSize(width: 1500, height: 500)
        #endif
    }
}
