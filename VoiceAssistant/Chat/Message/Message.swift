import Foundation

typealias MarkdownConvertible = String

struct Message: Identifiable, Equatable, Sendable {
    let id: String
    let timestamp: Date
    let content: MessageContent
}

enum MessageContent: Equatable, Sendable {
    case agentTranscript(MarkdownConvertible)
    case userTranscript(String)
}
