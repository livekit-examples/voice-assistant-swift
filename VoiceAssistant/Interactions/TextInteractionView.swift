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
                    ScreenShareView(namespace: namespace)
                    LocalParticipantView(namespace: namespace)
                    Spacer()
                }
                .frame(height: 50 * .grid)
                .safeAreaPadding()

                ChatView()
                #if os(macOS)
                    .frame(maxWidth: 128 * .grid)
                #endif
                    .mask(
                        LinearGradient(
                            gradient: Gradient(colors: [.clear, .black, .black]),
                            startPoint: .top,
                            endPoint: .init(x: 0.5, y: 0.2)
                        )
                    )
            }
            #if os(iOS)
            .contentShape(Rectangle())
            .onTapGesture {
                isKeyboardFocused = false
            }
            #endif

            ChatTextInputView(isKeyboardFocused: _isKeyboardFocused)
        }
    }
}
