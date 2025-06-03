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
                #if os(iOS)
                .frame(maxHeight: isKeyboardFocused ? 100 : 200)
                #else
                .frame(maxHeight: 200)
                #endif

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
            .animation(.default, value: isKeyboardFocused)
            .contentShape(Rectangle())
            .onTapGesture {
                isKeyboardFocused = false
            }
            #endif

            ChatTextInputView()
            #if os(iOS)
                .focused($isKeyboardFocused)
            #endif
        }
    }
}
