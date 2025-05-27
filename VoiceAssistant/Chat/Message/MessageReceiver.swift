import Foundation

protocol MessageReceiver: Sendable {
    func createMessageStream() async throws -> AsyncStream<ReceivedMessage>
}
