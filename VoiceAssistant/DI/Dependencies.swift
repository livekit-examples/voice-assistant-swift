import LiveKit

@MainActor
final class Dependencies {
    static let shared = Dependencies()

    private init() {}

    // MARK: LiveKit

    lazy var room = Room(roomOptions: RoomOptions(defaultScreenShareCaptureOptions: ScreenShareCaptureOptions(useBroadcastExtension: true)))

    // MARK: Services

    lazy var tokenService = TokenService()

    private lazy var topicMessageSender = TopicMessageSender(room: room)
    lazy var messageSenders: [any MessageSender] = [
        topicMessageSender,
    ]
    lazy var messageReceivers: [any MessageReceiver] = [
        TranscriptionStreamReceiver(room: room),
        topicMessageSender,
    ]

    // MARK: Error

    lazy var errorHandler: (Error?) -> Void = { _ in }
}

@MainActor
@propertyWrapper
struct Dependency<T> {
    let keyPath: KeyPath<Dependencies, T>

    init(_ keyPath: KeyPath<Dependencies, T>) {
        self.keyPath = keyPath
    }

    var wrappedValue: T {
        Dependencies.shared[keyPath: keyPath]
    }
}
