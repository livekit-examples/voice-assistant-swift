import Foundation
import IdentifiedCollections
import Observation

@MainActor
@Observable
final class ChatViewModel {
    private(set) var messages: IdentifiedArrayOf<Message> = []
    private(set) var error: Error?

    @ObservationIgnored
    private var messageObservers: [Task<Void, Never>] = []

    init(messageProviders: any MessageProvider...) {
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
    }
}
