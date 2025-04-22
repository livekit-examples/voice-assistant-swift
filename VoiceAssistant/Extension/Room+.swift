import Foundation
import LiveKit

extension Room {
    // Find the first agent participant in the room
    // This assumes there's only one agent and they publish only one audio track
    // Your application may have more complex requirements
    var agentParticipant: RemoteParticipant? {
        for participant in remoteParticipants.values {
            if participant.kind == .agent {
                return participant
            }
        }

        return nil
    }
}
