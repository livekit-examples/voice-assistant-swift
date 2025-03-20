import Foundation
import LiveKit
import MarkdownUI

actor TranscriptionProvider: MessageProvider {
    private typealias PartialID = String
    private typealias PartialContent = String

    private let chatTopic = "lk.chat"
    private let finalAttribute = "lk.transcription_final"

    private let room: Room

    private lazy var partialMessages: [PartialID: PartialContent] = [:]

    init(room: Room) {
        self.room = room
    }

    func createMessageStream() async throws -> AsyncStream<Message> {
        let (stream, continuation) = AsyncStream.makeStream(of: Message.self)

        try await room.registerTextStreamHandler(for: chatTopic) { [weak self] reader, participantIdentity in
            guard let self else { return }
            for try await message in reader where !message.isEmpty {
                continuation.yield(await processIncoming(message: message, reader: reader, participantIdentity: participantIdentity))
            }
        }

        continuation.onTermination = { _ in
            Task {
                await self.room.unregisterTextStreamHandler(for: self.chatTopic)
            }
        }

        return stream
    }
    
    private func processIncoming(message: String, reader: TextStreamReader, participantIdentity: Participant.Identity) -> Message {
        let partial = partialMessages[reader.info.id, default: ""]
        let updated = partial + message
        let message = Message(
            id: reader.info.id,
            timestamp: reader.info.timestamp,
            content: participantIdentity == room.localParticipant.identity ? .userTranscript(updated) : .agentTranscript(MarkdownContent(updated))
        )

        let partialID = reader.info.id
        if let isFinal = reader.info.attributes[finalAttribute], isFinal == "true" {
            partialMessages[partialID] = nil
        } else {
            partialMessages[partialID] = updated
        }
        for key in partialMessages.keys where key != partialID {
            partialMessages[key] = nil
        }
        
        return message
    }
}
