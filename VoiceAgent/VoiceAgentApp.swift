import LiveKit
import SwiftUI

/// The agent this app talks to. Edit ``current`` to switch.
enum AgentToConnect {
    struct HomepageTokenSource: EndpointTokenSource {
        let url = URL(string: "https://livekit.com/api/homepage-agent/token")!
    }

    /// The LiveKit homepage agent you can also try at https://livekit.com.
    /// Voice and text only: it does not accept video input.
    case liveKitHomepage

    /// Your own agent, reached through the LiveKit Cloud sandbox token server
    /// (development only):
    /// - Enable the token server from your project's Options on the
    ///   Settings page: https://cloud.livekit.io/projects/p_/settings/project
    /// - Pass the sandbox ID from that page here.
    case sandbox(id: String)

    /// Change this to `.sandbox(id: "your-sandbox-id")` to talk to your own agent.
    static let current: Self = .liveKitHomepage

    var tokenSource: any TokenSourceConfigurable {
        switch self {
        case .liveKitHomepage:
            HomepageTokenSource()
        case let .sandbox(id):
            SandboxTokenSource(id: id)
        }
    }

    /// Camera and screen share input, which requires a vision-capable agent.
    var videoEnabled: Bool {
        switch self {
        case .liveKitHomepage: false
        case .sandbox: true
        }
    }
}

@main
struct VoiceAgentApp: App {
    private let session: Session
    private let localMedia: LocalMedia
    private let audioOptions: AudioOptions

    init() {
        // The audio options panel applies its selection when the microphone
        // track is created. To guarantee that the very first captured frames
        // already use custom processing options, set them as room defaults
        // here instead, e.g.
        // RoomOptions(defaultAudioCaptureOptions: AudioCaptureOptions(echoCancellationMode: .software, ...))
        session = Session(
            tokenSource: AgentToConnect.current.tokenSource,
            options: SessionOptions(room: Room(roomOptions: RoomOptions(
                defaultScreenShareCaptureOptions: ScreenShareCaptureOptions(useBroadcastExtension: true)
            )))
        )
        localMedia = LocalMedia(session: session)
        audioOptions = AudioOptions(localMedia: localMedia)
    }

    var body: some Scene {
        WindowGroup {
            AppView()
                .environmentObject(session)
                .environmentObject(localMedia)
                .environmentObject(audioOptions)
                .environment(\.voiceEnabled, true)
                .environment(\.videoEnabled, AgentToConnect.current.videoEnabled)
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
