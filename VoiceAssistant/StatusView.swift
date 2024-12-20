import SwiftUI
import LiveKit
import LiveKitComponents

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

    var body: some View {
        if let track = agentParticipant?.firstAudioTrack {
            BarAudioVisualizer(audioTrack: track, barColor: .primary, barCount: 5)
        } else {
            Rectangle().fill(.clear)
        }
    }
}

