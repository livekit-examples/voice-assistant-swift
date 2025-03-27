import Foundation
@preconcurrency import LiveKit

/// An actor that converts raw text streams from the LiveKit `Room` into `Message` objects.
/// - Note: Streams are supported by `livekit-agents` >= 1.0.0.
/// - SeeAlso: ``TranscriptionDelegateReceiver``
///
/// New text stream is emitted for each message, and the stream is closed when the message is finalized.
/// Each message is delivered in chunks, that are accumulated and published into the message stream.
/// The ID of the message is the ID of the text stream, which is stable and unique across the lifetime of the message.
/// This ID can be used directly for `Identifiable` conformance.
///
/// Example text stream:
/// ```
/// { id: "1", content: "Hello" }
/// { id: "1", content: " world" }
/// { id: "1", content: "!" }
/// { id: "2", content: "Hello" }
/// { id: "2", content: " Apple" }
/// { id: "2", content: "!" }
/// ```
///
/// Example output:
/// ```
/// Message(id: "1", timestamp: 2025-01-01 12:00:00 +0000, content: .agentTranscript("Hello world!"))
/// Message(id: "2", timestamp: 2025-01-01 12:00:10 +0000, content: .agentTranscript("Hello Apple!"))
/// ```
///
actor TranscriptionStreamReceiver: MessageReceiver {
    private typealias PartialMessageID = String
    private struct PartialMessage {
        let content: String
        let originalTimestamp: Date
    }

    /// A predefined topic for the chat messages.
    private let transcriptionTopic = "lk.transcription"
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

        try await room.registerTextStreamHandler(for: transcriptionTopic) { [weak self] reader, participantIdentity in
            guard let self else { return }
            for try await message in reader where !message.isEmpty {
                await continuation.yield(processIncoming(message: message, reader: reader, participantIdentity: participantIdentity))
            }
        }

        continuation.onTermination = { _ in
            Task {
                await self.room.unregisterTextStreamHandler(for: self.transcriptionTopic)
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
