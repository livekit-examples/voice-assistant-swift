import Foundation

protocol MessageProvider {
    func createMessageStream() async throws -> AsyncStream<Message>
}
