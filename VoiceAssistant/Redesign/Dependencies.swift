//
//  Dependencies.swift
//  VoiceAssistant
//
//  Created by Blaze Pankowski on 22/05/2025.
//

import Foundation
import LiveKit

@MainActor
final class Dependencies {
    static let shared = Dependencies()

    private init() {}

    lazy var room = Room()
    lazy var tokenService = TokenService()
    lazy var transcriptionStreamReceiver = TranscriptionStreamReceiver(room: room)
}
