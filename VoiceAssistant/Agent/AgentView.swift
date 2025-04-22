import LiveKit
import LiveKitComponents
import SwiftUI

struct AgentView: View {
    @EnvironmentObject private var participant: Participant

    var body: some View {
        ZStack {
            let cameraTrack = participant.firstCameraVideoTrack
            let micTrack = participant.firstAudioTrack

            if let cameraTrack, !cameraTrack.isMuted {
                SwiftUIVideoView(cameraTrack)
            } else {
                AgentBarAudioVisualizer(audioTrack: micTrack, agentState: participant.agentState, barColor: .primary, barCount: 5)
            }
        }.id(participant.firstCameraVideoTrack?.sid)
    }
}
