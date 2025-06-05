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
                #if os(visionOS)
                VisionInteractionView(namespace: transitions)
                    .environment(chatViewModel)
                    .overlay(alignment: .bottom) {
                        agentListening()
                            .padding(16 * .grid)
                    }
                #else
                switch viewModel.interactionMode {
                case .text:
                    TextInteractionView(isKeyboardFocused: $isKeyboardFocused, namespace: transitions)
                        .environment(chatViewModel)
                case .voice:
                    VoiceInteractionView(namespace: transitions)
                        .overlay(alignment: .bottom) {
                            agentListening()
                                .padding()
                        }
                }
                #endif
            } else {
                StartView()
            }

            #if !os(visionOS)
            if case .reconnecting = viewModel.connectionState {
                WarningView(warning: "warning.reconnecting")
            }

            if let error {
                ErrorView(error: error) { self.error = nil }
            }
            #endif
        }
        #if os(visionOS)
        .ornament(attachmentAnchor: .scene(.bottom)) {
            if viewModel.hasConnection {
                ControlBar()
                    .glassBackgroundEffect()
            }
        }
        .alert("warning.reconnecting", isPresented: .constant(viewModel.connectionState == .reconnecting)) {}
        .alert(error?.localizedDescription ?? "error.title", isPresented: .constant(error != nil)) {
            Button("error.ok") { error = nil }
        }
        #else
        .safeAreaInset(edge: .bottom) {
                if viewModel.hasConnection, !isKeyboardFocused {
                    ControlBar()
                        .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity), removal: .opacity))
                }
            }
        #endif
            .background(Color.bg1)
            .animation(.default, value: viewModel.hasConnection)
            .animation(.default, value: viewModel.interactionMode)
            .animation(.default, value: viewModel.isCameraEnabled)
            .animation(.default, value: viewModel.isScreenShareEnabled)
            .animation(.default, value: error?.localizedDescription)
            .onAppear {
                Dependencies.shared.errorHandler = { error = $0 }
            }
        #if os(iOS)
            .sensoryFeedback(.impact, trigger: viewModel.isListening)
        #endif
    }

    @ViewBuilder
    private func agentListening() -> some View {
        ZStack {
            if chatViewModel.messages.isEmpty,
               !viewModel.isCameraEnabled,
               !viewModel.isScreenShareEnabled
            {
                AgentListeningView()
            }
        }
        .animation(.default, value: chatViewModel.messages.isEmpty)
    }
}

#Preview {
    AppView()
}
