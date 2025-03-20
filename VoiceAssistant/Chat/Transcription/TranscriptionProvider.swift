import Foundation
import LiveKit
import MarkdownUI

/// An actor that converts raw text streams from the LiveKit `Room` into `Message` objects.
///
/// New text stream is emitted for each message, and the stream is closed when the message is finalized.
/// Each message is delivered in chunks, that are accumulated and published into the message stream.
/// The ID of the message is the ID of the text stream, which is stable and unique across the lifetime of the message.
/// This ID can be used directly for `Identifiable` conformance.
actor TranscriptionProvider: MessageProvider {
    private typealias PartialID = String
    private typealias PartialContent = String

    /// A predefined topic for the chat messages.
    private let chatTopic = "lk.chat"
    /// The attribute that indicates if the message is finalized.
    private let finalAttribute = "lk.transcription_final"

    private let room: Room

    private lazy var partialMessages: [PartialID: PartialContent] = [:]

    init(room: Room) {
        self.room = room
    }

    /// Creates a new message stream for the chat topic.
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
    
    /// Aggregates the incoming text into a message, storing the partial content in the `partialMessages` dictionary.
    /// - Note: When the message is finalized, or a new message is started, the dictionary is cleared to limit memory usage.
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
