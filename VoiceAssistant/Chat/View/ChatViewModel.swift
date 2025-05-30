import AsyncAlgorithms
import Collections
import Foundation
import LiveKit
import Observation

/// A class that aggregates messages from multiple message providers
/// and exposes a single entry point for the UI to observe the message feed.
/// - Note: It may handle future interactions with the chat e.g. text input, etc.
@MainActor
@Observable
final class ChatViewModel {
    private(set) var messages: OrderedDictionary<ReceivedMessage.ID, ReceivedMessage> = [:]

    @ObservationIgnored
    @Dependency(\.room) private var room
    @ObservationIgnored
    @Dependency(\.messageReceivers) private var messageReceivers
    @ObservationIgnored
    @Dependency(\.messageSenders) private var messageSenders
    @ObservationIgnored
    @Dependency(\.errorHandler) private var errorHandler
    @ObservationIgnored
    private var messageObservers: [Task<Void, Never>] = []

    init() {
        for messageReceiver in messageReceivers {
            let observer = Task { [weak self] in
                guard let self else { return }
                do {
                    for await message in try await messageReceiver
                        .createMessageStream()
                        ._throttle(for: .milliseconds(100))
                    {
                        messages.updateValue(message, forKey: message.id)
                    }
                } catch {
                    errorHandler(error)
                }
            }
            messageObservers.append(observer)
        }

        Task { @MainActor [weak self] in
            guard let changes = self?.room.changes else { return }
            for await _ in changes {
                guard let self else { return }
                if room.connectionState == .disconnected {
                    clearHistory()
                }
            }
        }
    }

    deinit {
        messageObservers.forEach { $0.cancel() }
    }

    private func clearHistory() {
        messages.removeAll()
    }

    func sendMessage(_ text: String) async {
        let message = SentMessage(id: UUID().uuidString, timestamp: Date(), content: .userText(text))
        do {
            for sender in messageSenders {
                try await sender.send(message)
            }
        } catch {
            errorHandler(error)
        }
    }
}
