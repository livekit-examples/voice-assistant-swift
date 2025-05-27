//
//  TextInteractionView.swift
//  VoiceAssistant
//
//  Created by Blaze Pankowski on 23/05/2025.
//

import SwiftUI

struct TextInteractionView: View {
    @Environment(AppViewModel.self) private var viewModel
    @Environment(ChatViewModel.self) private var chatViewModel

    var namespace: Namespace.ID

    var body: some View {
        VStack {
            HStack {
                AgentParticipantView(namespace: namespace)
                    .frame(maxWidth: 120, maxHeight: 200)
                LocalParticipantView(namespace: namespace)
                    .frame(maxWidth: 120, maxHeight: 200)
            }
            ChatView()
                .mask(
                    LinearGradient(
                        gradient: Gradient(colors: [.clear, .black, .black]),
                        startPoint: .top,
                        endPoint: .init(x: 0.5, y: 0.2)
                    )
                )
        }
        .safeAreaInset(edge: .bottom) {
            VStack {
                ChatTextInputView()
                ControlBar()
            }
        }
    }
}
