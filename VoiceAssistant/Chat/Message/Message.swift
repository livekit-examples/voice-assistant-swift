import Foundation
import MarkdownUI

struct Message: Identifiable, Equatable {
    let id: String
    let timestamp: Date
    let content: MessageContent
}

enum MessageContent: Equatable {
    case agentTranscript(MarkdownContent)
    case userTranscript(String)
}
