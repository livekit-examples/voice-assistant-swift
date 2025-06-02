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

    @FocusState.Binding var isKeyboardFocused: Bool
    var namespace: Namespace.ID

    var body: some View {
        VStack {
            VStack {
                HStack {
                    Spacer()
                    AgentParticipantView(namespace: namespace)
                        .frame(maxWidth: 120)
                    LocalParticipantView(namespace: namespace)
                        .frame(maxWidth: 120)
                    ScreenShareView(namespace: namespace)
                        .frame(maxWidth: 200)
                    Spacer()
                }
                .frame(maxHeight: isKeyboardFocused ? 100 : 200)

                ChatView()
                    .mask(
                        LinearGradient(
                            gradient: Gradient(colors: [.clear, .black, .black]),
                            startPoint: .top,
                            endPoint: .init(x: 0.5, y: 0.2)
                        )
                    )
                    .containerRelativeFrame(.horizontal)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                isKeyboardFocused = false
            }

            ChatTextInputView()
                .focused($isKeyboardFocused)
        }
    }
}
