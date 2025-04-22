import LiveKit
import LiveKitComponents
import SwiftUI

struct AgentView: View {
    @EnvironmentObject private var room: Room
    @EnvironmentObject private var participant: Participant

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
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                AgentBarAudioVisualizer(audioTrack: micTrack, agentState: participant.agentState, barColor: .primary, barCount: 5)
            }
        }
    }
}
