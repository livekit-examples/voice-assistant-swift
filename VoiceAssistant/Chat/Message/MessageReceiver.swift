import Foundation

protocol MessageReceiver {
    func createMessageStream() async throws -> AsyncStream<Message>
}
