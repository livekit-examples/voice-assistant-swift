import Foundation
import AsyncAlgorithms
import IdentifiedCollections
import Observation

@Observable
final class ChatViewModel {
    private(set) var messages: IdentifiedArrayOf<Message> = []
    
    @ObservationIgnored private var messageObservers: [Task<Void, Never>] = []

    init(messageProviders: any MessageProvider...) {
        for messageProvider in messageProviders {
            messageObservers.append(Task {
                for await message in messageProvider.createMessageStream() {
                    messages.updateOrAppend(message)
                }
            })
        }
    }
    
    deinit {
        messageObservers.forEach { $0.cancel() }
    }
}
