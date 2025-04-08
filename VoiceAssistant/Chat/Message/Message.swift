import Foundation

struct Message: Identifiable, Equatable, Sendable {
    let id: String
    let timestamp: Date
    let content: Content

    enum Content: Equatable, Sendable {
        case agentTranscript(String)
        case userTranscript(String)
    }
}
