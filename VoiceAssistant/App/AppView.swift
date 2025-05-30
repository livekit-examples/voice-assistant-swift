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

    @State private var error: Error?

    @Namespace private var transitions

    var body: some View {
        ZStack(alignment: .top) {
            switch viewModel.connectionState {
            case .disconnected where viewModel.isListening,
                 .connecting where viewModel.isListening,
                 .connected,
                 .reconnecting:
                switch viewModel.interactionMode {
                case .text: TextInteractionView(namespace: transitions).environment(chatViewModel)
                case .voice: VoiceInteractionView(namespace: transitions)
                }
            case .disconnected, .connecting: StartView()
            }

            if case .reconnecting = viewModel.connectionState {
                WarningView(warning: "warning.reconnecting")
            }

            if let error {
                ErrorView(error: error) { self.error = nil }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background1)
        .animation(.default, value: viewModel.connectionState)
        .animation(.default, value: viewModel.interactionMode)
        .animation(.default, value: viewModel.isCameraEnabled)
        .animation(.default, value: viewModel.isScreenShareEnabled)
        .animation(.default, value: viewModel.agent)
        .animation(.default, value: error?.localizedDescription)
        .onAppear {
            Dependencies.shared.errorHandler = { error = $0 }
        }
        .sensoryFeedback(.impact, trigger: viewModel.isListening)
    }
}

#Preview {
    AppView()
}
