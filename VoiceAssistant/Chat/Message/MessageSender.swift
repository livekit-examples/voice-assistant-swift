import Foundation

protocol MessageSender: Sendable {
    func send(message: String) async throws
}
