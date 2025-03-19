//
//  MessageProvider.swift
//  VoiceAssistant
//
//  Created by Blaze Pankowski on 18/03/2025.
//

import Foundation

protocol MessageProvider {
    func createMessageStream() async throws -> AsyncStream<Message>
}
