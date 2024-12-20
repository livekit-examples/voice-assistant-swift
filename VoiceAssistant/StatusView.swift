import LiveKit
import LiveKitComponents
import SwiftUI

struct StatusView: View {
    @EnvironmentObject private var room: Room

    private var agentParticipant: RemoteParticipant? {
        for participant in room.remoteParticipants.values {
            if participant.kind == .agent {
                return participant
            }
        }

        return nil
    }

    private var agentState: AgentState? {
        agentParticipant?.agentState ?? .initializing
    }

    var body: some View {
        if let track = agentParticipant?.firstAudioTrack {
            BarAudioVisualizer(audioTrack: track, barColor: .primary, barCount: 5)
                .opacity(agentState == .speaking ? 1 : 0.3)
                .animation(
                    .easeInOut(duration: 1)
                        .repeatForever(autoreverses: true)
                        .speed(agentState == .thinking ? 2 : 1),
                    value: agentState)
        } else {
            Rectangle().fill(.clear)
        }
    }
}
