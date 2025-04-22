import LiveKit
import LiveKitComponents
import SwiftUI

struct AgentView: View {
    @EnvironmentObject private var room: Room
    @EnvironmentObject private var participant: Participant
    @State private var isFullScreen = false

    private var worker: RemoteParticipant? {
        room.remoteParticipants.values.first { $0.kind == .agent && $0.attributes["lk.publish_on_behalf"] == participant.identity?.stringValue }
    }

    private var cameraTrack: VideoTrack? {
        return participant.firstCameraVideoTrack ?? worker?.firstCameraVideoTrack
    }

    private var micTrack: AudioTrack? {
        return participant.firstAudioTrack ?? worker?.firstAudioTrack
    }

    var body: some View {
        ZStack {
            if let cameraTrack, !cameraTrack.isMuted {
                SwiftUIVideoView(cameraTrack)
                    .overlay(alignment: .topTrailing) {
                        Button(action: {
                            withAnimation {
                                isFullScreen.toggle()
                            }
                        }) {
                            Image(systemName: isFullScreen ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                                .font(.system(size: 20))
                                .padding(8)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                        .padding(8)
                    }
            } else {
                AgentBarAudioVisualizer(audioTrack: micTrack, agentState: participant.agentState, barColor: .primary, barCount: 5)
            }
        }
        .frame(maxWidth: isFullScreen ? .infinity : 256, maxHeight: isFullScreen ? .infinity : 256)
        .id("agent-\(participant.identity.stringValue)-\(cameraTrack?.sid?.stringValue ?? "none")-\(micTrack?.sid?.stringValue ?? "none")")
    }
}
