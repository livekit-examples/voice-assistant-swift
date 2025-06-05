import SwiftUI

struct MultiplatformInteractionView: View {
    @Environment(AppViewModel.self) private var viewModel
    @Environment(ChatViewModel.self) private var chatViewModel
    @FocusState private var isKeyboardFocused: Bool
    var namespace: Namespace.ID

    var body: some View {
        switch viewModel.interactionMode {
        case .text:
            TextInteractionView(isKeyboardFocused: $isKeyboardFocused, namespace: namespace)
                .environment(chatViewModel)
        case .voice:
            VoiceInteractionView(namespace: namespace)
                .animation(.default, value: chatViewModel.messages.isEmpty)
        }
    }
}
