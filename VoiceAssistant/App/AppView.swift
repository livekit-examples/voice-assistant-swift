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
            case .connecting where viewModel.isListening, .connected, .reconnecting:
                switch viewModel.interactionMode {
                case .text: TextInteractionView(namespace: transitions).environment(chatViewModel)
                case .voice: VoiceInteractionView(namespace: transitions)
                }
            case .disconnected, .connecting: StartView()
            }

            if let error {
                ErrorView(error: error) { self.error = nil }
            }
        }
        .animation(.default, value: viewModel.connectionState)
        .animation(.default, value: viewModel.interactionMode)
        .animation(.default, value: viewModel.video == nil)
        .onAppear {
            Dependencies.shared.errorHandler = { error = $0 }
        }
    }
}

#Preview {
    AppView()
}
