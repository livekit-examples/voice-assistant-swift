import Foundation
import IdentifiedCollections
import LiveKit
import Observation

@MainActor
@Observable
final class ChatViewModel {
    private(set) var messages: IdentifiedArrayOf<Message> = []
    private(set) var error: Error?

    @ObservationIgnored
    private let room: Room
    @ObservationIgnored
    private var messageObservers: [Task<Void, Never>] = []

    init(room: Room, messageProviders: any MessageProvider...) {
        self.room = room
        room.add(delegate: self)

        for messageProvider in messageProviders {
            let observer = Task {
                do {
                    for await message in try await messageProvider.createMessageStream() {
                        self.messages.updateOrAppend(message)
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
