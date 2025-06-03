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
                case .text:
                    TextInteractionView(isKeyboardFocused: $isKeyboardFocused, namespace: transitions)
                        .environment(chatViewModel)
                case .voice:
                    VoiceInteractionView(namespace: transitions)
                        .overlay(alignment: .bottom) {
                            if chatViewModel.messages.isEmpty,
                               !viewModel.isCameraEnabled,
                               !viewModel.isScreenShareEnabled
                            {
                                AgentListeningView()
                                    .padding()
                            }
                        }
                        .animation(.default, value: chatViewModel.messages.isEmpty)
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
        #if os(visionOS)
        .ornament(attachmentAnchor: .scene(.bottom)) {
            if viewModel.hasConnection {
                ControlBar()
                    .glassBackgroundEffect()
            }
        }
        #else
        .safeAreaInset(edge: .bottom) {
                if viewModel.hasConnection, !isKeyboardFocused {
                    ControlBar()
                }
            }
        #endif
            .background(Color.bg1)
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
