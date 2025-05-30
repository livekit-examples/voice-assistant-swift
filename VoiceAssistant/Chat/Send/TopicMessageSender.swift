import Foundation
import LiveKit

actor TopicMessageSender: MessageSender, MessageReceiver {
    private let room: Room
    private let topic: String

    private var messageContinuation: AsyncStream<ReceivedMessage>.Continuation?

    init(room: Room, topic: String = "lk.chat") {
        self.room = room
        self.topic = topic
    }

    func send(_ message: SentMessage) async throws {
        guard case let .userText(text) = message.content else { return }

        try await room.localParticipant.sendText(text, for: topic)

        let loopbackMessage = ReceivedMessage(
            id: UUID().uuidString,
            timestamp: Date(),
            content: .userTranscript(text)
        )

        messageContinuation?.yield(loopbackMessage)
    }

    func createMessageStream() async throws -> AsyncStream<ReceivedMessage> {
        let (stream, continuation) = AsyncStream<ReceivedMessage>.makeStream()
        messageContinuation = continuation
        return stream
    }
}
