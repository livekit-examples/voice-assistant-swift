import Foundation

struct Message: Identifiable, Equatable {
    let id: String
    let timestamp: Date
    let content: MessageContent
}

enum MessageContent: Equatable {
    case agentTranscript(String)
    case userTranscript(String)
}
