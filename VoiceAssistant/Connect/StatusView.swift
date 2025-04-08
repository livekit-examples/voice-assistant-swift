import LiveKit
import LiveKitComponents
import SwiftUI

/// Shows a visualizer for the agent participant in the room
/// In a more complex app, you may want to show more information here
struct StatusView: View {
    // Load the room from the environment
    @EnvironmentObject private var room: Room

    var body: some View {
        if let participant = room.agentParticipant {
            AgentBarAudioVisualizer(audioTrack: participant.firstAudioTrack, agentState: room.agentState, barColor: .primary, barCount: 5)
                .id(participant.firstAudioTrack?.id)
        }
    }
}
