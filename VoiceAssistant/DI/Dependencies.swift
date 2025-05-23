//
//  Dependencies.swift
//  VoiceAssistant
//
//  Created by Blaze Pankowski on 22/05/2025.
//

import LiveKit

@MainActor
final class Dependencies {
    static let shared = Dependencies()

    private init() {}

    // MARK: LiveKit

    lazy var room = Room()

    // MARK: Services

    lazy var tokenService = TokenService()
    lazy var messageReceivers: [any MessageReceiver] = [TranscriptionStreamReceiver(room: room)]
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
