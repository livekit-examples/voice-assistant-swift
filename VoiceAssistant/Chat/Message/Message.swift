import Foundation

struct ReceivedMessage: Identifiable, Equatable, Sendable {
    let id: String
    let timestamp: Date
    let content: Content

    enum Content: Equatable, Sendable {
        case agentTranscript(String)
        case userTranscript(String)
    }
}

struct SentMessage: Identifiable, Equatable, Sendable {
    let id: String
    let timestamp: Date
    let content: Content

    enum Content: Equatable, Sendable {
        case userText(String)
    }
}
