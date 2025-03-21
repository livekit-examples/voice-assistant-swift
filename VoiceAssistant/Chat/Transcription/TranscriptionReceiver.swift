import Foundation
@preconcurrency import LiveKit

/// An actor that converts raw text streams from the LiveKit `Room` into `Message` objects.
///
/// New text stream is emitted for each message, and the stream is closed when the message is finalized.
/// Each message is delivered in chunks, that are accumulated and published into the message stream.
/// The ID of the message is the ID of the text stream, which is stable and unique across the lifetime of the message.
/// This ID can be used directly for `Identifiable` conformance.
actor TranscriptionReceiver: MessageReceiver {
    private typealias PartialMessageID = String
    private struct PartialMessage {
        let content: String
        let originalTimestamp: Date
    }

    /// A predefined topic for the chat messages.
    private let chatTopic = "lk.chat"
    /// The attribute that indicates if the message is finalized.
    private let finalAttribute = "lk.transcription_final"

    private let room: Room

    private lazy var partialMessages: [PartialMessageID: PartialMessage] = [:]

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
    /// - Note: When the message is finalized, or a new message is started, the dictionary is purged to limit memory usage.
    private func processIncoming(message: String, reader: TextStreamReader, participantIdentity: Participant.Identity) -> Message {
        let partialID = reader.info.id
        let timestamp: Date
        let updatedContent: String
        
        if let existingInfo = partialMessages[partialID] {
            // Use the existing content and the original timestamp
            updatedContent = existingInfo.content + message
            timestamp = existingInfo.originalTimestamp
        } else {
            // This is a new message, use the current timestamp
            updatedContent = message
            timestamp = reader.info.timestamp
        }
        
        let newOrUpdatedMessage = Message(
            id: partialID,
            timestamp: timestamp,
            content: participantIdentity == room.localParticipant.identity ? .userTranscript(updatedContent) : .agentTranscript(updatedContent)
        )

        // Clear reader's own partial messages if it's final
        if let isFinal = reader.info.attributes[finalAttribute], isFinal == "true" {
            partialMessages[partialID] = nil
        } else {
            partialMessages[partialID] = PartialMessage(content: updatedContent, originalTimestamp: timestamp)
        }
        
        // Clear other partial messages when a new one starts
        for key in partialMessages.keys where key != partialID {
            partialMessages[key] = nil
        }
        
        return newOrUpdatedMessage
    }
}
