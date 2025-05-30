import Foundation

protocol MessageSender: Sendable {
    func send(_ message: SentMessage) async throws
}
