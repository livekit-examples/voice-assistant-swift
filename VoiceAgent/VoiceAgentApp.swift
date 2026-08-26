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

    /// Your own agent, reached through the LiveKit Cloud
    /// [development token server](https://docs.livekit.io/frontends/build/authentication/development-token-server/)
    /// (development only):
    /// - Switch on the Development token server toggle on your project's
    ///   Settings page: https://cloud.livekit.io/projects/p_/settings/project
    /// - Pass the Token server ID shown below the toggle here.
    case development(id: String)

    /// Change this to `.development(id: "your-token-server-id")` to talk to your own agent.
    static let current: Self = .liveKitHomepage

    var tokenSource: any TokenSourceConfigurable {
        switch self {
        case .liveKitHomepage:
            HomepageTokenSource()
        case let .development(id):
            DevelopmentTokenSource(id: id)
        }
    }

    /// Camera and screen share input, which requires a vision-capable agent.
    var videoEnabled: Bool {
        switch self {
        case .liveKitHomepage: false
        case .development: true
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
