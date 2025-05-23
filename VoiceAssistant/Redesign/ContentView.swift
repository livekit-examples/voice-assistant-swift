//
//  ContentView.swift
//  VoiceAssistant
//
//  Created by Blaze Pankowski on 22/05/2025.
//

import SwiftUI

struct ContentView: View {
    @Environment(AppViewModel.self) private var viewModel
    @State private var chatViewModel = ChatViewModel()

    var body: some View {
        Group {
            switch (viewModel.connectionState, viewModel.inputMode) {
            case (.disconnected, _):
                StartView()
//            case .connecting where !viewModel.state.isListening:
            case (.connecting, _):
                StartView()
            case (.connected, .text):
                ChatView()
                    .environment(chatViewModel)
                    .safeAreaInset(edge: .bottom) {
                        CallBar()
                    }
            case (.connected, .voice):
                CallView()
                    .safeAreaInset(edge: .bottom) {
                        CallBar()
                    }
            case (.reconnecting, _):
                Text("Reconnecting...")
            }
        }
        .animation(.default, value: viewModel.connectionState)
        .animation(.default, value: viewModel.inputMode)
    }
}

#Preview {
    ContentView()
}
