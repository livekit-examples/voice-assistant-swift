import LiveKit
import Foundation

actor TranscriptionMessageProvider: MessageProvider {
    private typealias PartialID = String
    private typealias PartialContent = String
    
    private let chatTopic = "lk.chat"
    private let finalAttribute = "lk.transcription_final"
    
    private let room: Room

    private lazy var partialMessages: [PartialID: PartialContent] = [:]

    init(room: Room) {
        self.room = room
    }

    func createMessageStream() async -> AsyncStream<Message> {
        let (stream, continuation) = AsyncStream.makeStream(of: Message.self)
        
        try? await room.registerTextStreamHandler(for: chatTopic) { [weak self] reader, participantIdentity in
            guard let self else { return }
            for try await message in reader where !message.isEmpty {
                let partial = await partialMessages[reader.info.id, default: ""]
                let updated = partial + message
                let message = await Message(
                    id: reader.info.id,
                    timestamp: reader.info.timestamp,
                    content: participantIdentity == room.localParticipant.identity ? .userTranscript(updated) : .agentTranscript(updated)
                )

                continuation.yield(message)
                
                if let isFinal = reader.info.attributes[finalAttribute], isFinal == "true" {
                    await setPartial(nil, id: reader.info.id)
                } else {
                    await setPartial(updated, id: reader.info.id)
                }
                for key in await partialMessages.keys where key != reader.info.id {
                    await setPartial(nil, id: key)
                }
            }
        }
        
        continuation.onTermination = { [weak room] _ in
            Task {
                await room?.unregisterTextStreamHandler(for: self.chatTopic)
            }
        }
        
        return stream
    }
    
    private func setPartial(_ content: PartialContent?, id: PartialID) {
        partialMessages[id] = content
    }
}
