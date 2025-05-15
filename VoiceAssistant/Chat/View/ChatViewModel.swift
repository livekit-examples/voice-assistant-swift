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
    private(set) var messages: OrderedDictionary<Message.ID, Message> = [:]
    private(set) var error: Error?

    @ObservationIgnored
    private let room: Room
    @ObservationIgnored
    private var messageObservers: [Task<Void, Never>] = []

    init(room: Room, messageReceivers: any MessageReceiver...) {
        self.room = room
        room.add(delegate: self)

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
                    self.error = error
                }
            }
            messageObservers.append(observer)
        }
    }

    deinit {
        messageObservers.forEach { $0.cancel() }
        room.remove(delegate: self)
    }

    private func clearHistory() {
        messages.removeAll()
    }
}

extension ChatViewModel: RoomDelegate {
    nonisolated func room(_: Room, didDisconnectWithError _: LiveKitError?) {
        Task { @MainActor in
            clearHistory()
        }
    }
}
