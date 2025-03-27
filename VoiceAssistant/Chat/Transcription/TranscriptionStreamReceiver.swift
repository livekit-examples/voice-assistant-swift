import Foundation
@preconcurrency import LiveKit

/// An actor that converts raw text streams from the LiveKit `Room` into `Message` objects.
/// - Note: Streams are supported by `livekit-agents` >= 1.0.0.
/// - SeeAlso: ``TranscriptionDelegateReceiver``
///
/// For agent messages, new text stream is emitted for each message, and the stream is closed when the message is finalized.
/// Each agent message is delivered in chunks, that are accumulated and published into the message stream.
///
/// For user messages, the full transcription is sent each time, but may be updated until finalized.
///
/// The ID of the message is the ID of the text stream, which is stable and unique across the lifetime of the message.
/// This ID can be used directly for `Identifiable` conformance.
///
/// Example text stream for agent messages:
/// ```
/// { id: "1", content: "Hello" }
/// { id: "1", content: " world" }
/// { id: "1", content: "!" }
/// { id: "2", content: "Hello" }
/// { id: "2", content: " Apple" }
/// { id: "2", content: "!" }
/// ```
///
/// Example text stream for user messages:
/// ```
/// { id: "3", content: "Hello world" }
/// { id: "3", content: "Hello world!" }
/// { id: "4", content: "Hello Apple" }
/// { id: "4", content: "Hello Apple!" }
/// ```
///
/// Example output:
/// ```
/// Message(id: "1", timestamp: 2025-01-01 12:00:00 +0000, content: .agentTranscript("Hello world!"))
/// Message(id: "2", timestamp: 2025-01-01 12:00:10 +0000, content: .agentTranscript("Hello Apple!"))
/// Message(id: "3", timestamp: 2025-01-01 12:00:20 +0000, content: .userTranscript("Hello world!"))
/// Message(id: "4", timestamp: 2025-01-01 12:00:30 +0000, content: .userTranscript("Hello Apple!"))
/// ```
///
actor TranscriptionStreamReceiver: MessageReceiver {
    private struct PartialMessageID: Hashable {
        let streamID: String
        let participantID: Participant.Identity
    }

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
        let partialID = PartialMessageID(streamID: reader.info.id, participantID: participantIdentity)
        let timestamp: Date
        let updatedContent: String

        if let existingInfo = partialMessages[partialID] {
            // Use the existing content and the original timestamp
            updatedContent = shouldOverwriteMessages(from: participantIdentity) ? message : existingInfo.content + message
            timestamp = existingInfo.originalTimestamp
        } else {
            // This is a new message, use the current timestamp
            updatedContent = message
            timestamp = reader.info.timestamp
        }

        let newOrUpdatedMessage = Message(
            id: partialID.streamID,
            timestamp: timestamp,
            content: participantIdentity == room.localParticipant.identity ? .userTranscript(updatedContent) : .agentTranscript(updatedContent)
        )
        
        #warning("Remove")
        print(message, reader.info.id, reader.info.attributes)

        // Clear reader's current partial messages if it's final
        if let isFinal = reader.info.attributes[finalAttribute], isFinal == "true" {
            partialMessages[partialID] = nil
        } else {
            partialMessages[partialID] = PartialMessage(content: updatedContent, originalTimestamp: timestamp)
        }

        // Clear reader's old partial messages when a new turn starts
        for key in partialMessages.keys where key != partialID && key.participantID == participantIdentity {
            partialMessages[key] = nil
        }
        
        assert(partialMessages.count <= 2, "There should be max 1 partial message entry per participant.")

        return newOrUpdatedMessage
    }
    
    /// Determines if the incoming message should override the existing partial message.
    /// - Note: This applies to local user messages as they are sent in full.
    private func shouldOverwriteMessages(from participantIdentity: Participant.Identity) -> Bool {
        participantIdentity == room.localParticipant.identity
    }
}
