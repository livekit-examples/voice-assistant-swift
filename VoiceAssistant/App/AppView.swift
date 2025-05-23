//
//  AppView.swift
//  VoiceAssistant
//
//  Created by Blaze Pankowski on 23/05/2025.
//

import SwiftUI

struct AppView: View {
    @Environment(AppViewModel.self) private var viewModel
    @State private var chatViewModel = ChatViewModel()
    @Namespace private var transitions

    var body: some View {
        Group {
            switch (viewModel.connectionState, viewModel.inputMode) {
            case (.disconnected, _):
                StartView()
            case (.connecting, _):
                StartView()
            case (.connected, .text):
                TextInteractionView(namespace: transitions)
                    .environment(chatViewModel)
            case (.connected, .voice):
                VoiceInteractionView(namespace: transitions)
            case (.reconnecting, _):
                Text("Reconnecting...")
            }
        }
        .animation(.default, value: viewModel.connectionState)
        .animation(.default, value: viewModel.inputMode)
        .animation(.default, value: viewModel.video)
    }
}

#Preview {
    AppView()
}
