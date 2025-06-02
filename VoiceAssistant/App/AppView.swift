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
    @FocusState private var isKeyboardFocused: Bool

    @Namespace private var transitions

    var body: some View {
        ZStack(alignment: .top) {
            if viewModel.hasConnection {
                switch viewModel.interactionMode {
                case .text: TextInteractionView(isKeyboardFocused: $isKeyboardFocused, namespace: transitions)
                    .environment(chatViewModel)
                case .voice: VoiceInteractionView(namespace: transitions)
                }
            } else {
                StartView()
            }

            if case .reconnecting = viewModel.connectionState {
                WarningView(warning: "warning.reconnecting")
            }

            if let error {
                ErrorView(error: error) { self.error = nil }
            }
        }
        .safeAreaInset(edge: .bottom) {
            if viewModel.hasConnection, !isKeyboardFocused {
                ControlBar()
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
        #if os(iOS)
        .sensoryFeedback(.impact, trigger: viewModel.isListening)
        #endif
    }
}

#Preview {
    AppView()
}
