//
//  ContentView.swift
//  VoiceAssistant
//
//  Created by Blaze Pankowski on 22/05/2025.
//

import LiveKitComponents

struct ContentView: View {
    @Environment(AppViewModel.self) private var viewModel
    @State private var chatViewModel = ChatViewModel()
    @Namespace private var participantNamespace

    var body: some View {
        Group {
            switch (viewModel.connectionState, viewModel.inputMode) {
            case (.disconnected, _):
                StartView()
//            case .connecting where !viewModel.state.isListening:
            case (.connecting, _):
                StartView()
            case (.connected, .text):
                VStack {
                    HStack {
                        if let agent = viewModel.agent {
                            ParticipantView(showInformation: false)
                                .environmentObject(agent)
                                .frame(maxWidth: 120)
                                .matchedGeometryEffect(id: "participant", in: participantNamespace)
                        }
                    }
                    .frame(height: 120)
                    ChatView()
                        .environment(chatViewModel)
                        .safeAreaInset(edge: .bottom) {
                            CallBar()
                        }
                }
            case (.connected, .voice):
                if let agent = viewModel.agent {
                    ParticipantView(showInformation: false)
                        .environmentObject(agent)
                        .matchedGeometryEffect(id: "participant", in: participantNamespace)
                        .safeAreaInset(edge: .bottom) {
                            CallBar()
                        }
                } else {
                    Text("No agent")
                        .safeAreaInset(edge: .bottom) {
                            CallBar()
                        }
                }
            case (.reconnecting, _):
                Text("Reconnecting...")
            }
        }
        .animation(.default, value: viewModel.connectionState)
        .animation(.default, value: viewModel.inputMode)
    }
}

#Preview {
    ContentView()
}
