import LiveKit
import Foundation

final class TranscriptionMessageProvider: MessageProvider {
    private let room: Room
    private var continuation: AsyncStream<Message>.Continuation?

    init(room: Room) {
        self.room = room
        room.add(delegate: self)
    }

    deinit {
        room.remove(delegate: self)
    }

    func createMessageStream() -> AsyncStream<Message> {
        let (stream, continuation) = AsyncStream.makeStream(of: Message.self)
        self.continuation = continuation
        return stream
    }
}

extension TranscriptionMessageProvider: RoomDelegate {
    func room(_ room: Room, participant: Participant, trackPublication: TrackPublication, didReceiveTranscriptionSegments segments: [TranscriptionSegment]) {
        segments
            .filter { !$0.text.isEmpty }
            .forEach { segment in
        let message = Message(
            id: segment.id,
            timestamp: segment.lastReceivedTime,
            content: participant.kind == .agent ? .agentTranscript(segment.text) : .userTranscript(segment.text)
        )
        continuation?.yield(message)
        }
    }
}
