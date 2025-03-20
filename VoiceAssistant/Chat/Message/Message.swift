import Foundation
@preconcurrency import MarkdownUI

struct Message: Identifiable, Equatable, Sendable {
    let id: String
    let timestamp: Date
    let content: MessageContent
}

enum MessageContent: Equatable, Sendable {
    case agentTranscript(MarkdownContent)
    case userTranscript(String)
}
