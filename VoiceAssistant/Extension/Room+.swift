import Foundation
import LiveKit

extension Room {
    // Find the first agent participant in the room
    // This also filters out avatar workers but otherwise assumes there's only one agent
    var agentParticipant: RemoteParticipant? {
        for participant in remoteParticipants.values {
            if participant.kind == .agent && !participant.attributes.keys.contains("lk.publish_on_behalf") {
                return participant
            }
        }

        return nil
    }
}
