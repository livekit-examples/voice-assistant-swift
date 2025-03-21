import Foundation

typealias MarkdownConvertible = String

struct Message: Identifiable, Equatable, Sendable {
    let id: String
    let timestamp: Date
    let content: Content

    enum Content: Equatable, Sendable {
        case agentTranscript(MarkdownConvertible)
        case userTranscript(String)
    }
}
