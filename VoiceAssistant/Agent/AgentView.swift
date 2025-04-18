import LiveKit
import LiveKitComponents
import SwiftUI

struct AgentView: View {
    @EnvironmentObject private var room: Room

    var body: some View {
        ZStack {
            if let agent = room.agentParticipant {
                let micTrack = agent.firstAudioTrack
                let cameraTrack = agent.firstCameraVideoTrack
                
                if let cameraTrack, !cameraTrack.isMuted {
                    SwiftUIVideoView(cameraTrack)
                        .overlay(alignment: .topTrailing) {
                            AgentBarAudioVisualizer(audioTrack: micTrack, agentState: room.agentState, barColor: .primary, barCount: 5)
                                .frame(width: 100, height: 50)
                                .padding()
                        }
                } else {
                    AgentBarAudioVisualizer(audioTrack: micTrack, agentState: room.agentState, barColor: .primary, barCount: 5)
                }
            }
        }
    }
}
