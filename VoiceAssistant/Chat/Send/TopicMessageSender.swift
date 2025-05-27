import Foundation
import LiveKit

actor TopicMessageSender: MessageSender {
    private let room: Room
    private let topic: String

    init(room: Room, topic: String = "lk.chat") {
        self.room = room
        self.topic = topic
    }

    func send(message: String) async throws {
        try await room.localParticipant.sendText(message, for: topic)
    }
}
