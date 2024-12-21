//
//  VoiceAssistantApp.swift
//  VoiceAssistant
//
//  Created by Ben Cherry on 12/17/24.
//

import SwiftUI

@main
struct VoiceAssistantApp: App {
    private var tokenService: TokenService = .init()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(tokenService)
        }
    }
}
