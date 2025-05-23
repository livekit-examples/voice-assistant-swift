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
    @Namespace private var transitions

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
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .shadow(radius: 20, y: 10)
                                .matchedGeometryEffect(id: "agent", in: transitions)
                        }
                        if let video = viewModel.video {
                            ParticipantView(showInformation: false)
                                .environmentObject(viewModel.localParticipant)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .aspectRatio(video.aspectRatio, contentMode: .fit)
                                .frame(maxWidth: 120, maxHeight: 120)
                                .shadow(radius: 20, y: 10)
                                .matchedGeometryEffect(id: "local", in: transitions)
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
                ZStack(alignment: .topTrailing) {
                    if let agent = viewModel.agent {
                        ParticipantView(showInformation: false)
                            .environmentObject(agent)
                            .matchedGeometryEffect(id: "agent", in: transitions)
                            .safeAreaInset(edge: .bottom) {
                                CallBar()
                            }
                    } else {
                        Text("No agent")
                            .safeAreaInset(edge: .bottom) {
                                CallBar()
                            }
                    }

                    if let video = viewModel.video {
                        ParticipantView(showInformation: false)
                            .environmentObject(viewModel.localParticipant)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .aspectRatio(video.aspectRatio, contentMode: .fit)
                            .frame(maxWidth: 200, maxHeight: 200)
                            .shadow(radius: 20, y: 10)
                            .matchedGeometryEffect(id: "local", in: transitions)
                            .padding()
                    }
                }
            case (.reconnecting, _):
                Text("Reconnecting...")
            }
        }
        .animation(.default, value: viewModel.connectionState)
        .animation(.default, value: viewModel.inputMode)
        .animation(.default, value: viewModel.video)
    }
}

#Preview {
    ContentView()
}

extension TrackPublication {
    var aspectRatio: CGFloat {
        guard let dimensions else { return 1 }
        return CGFloat(dimensions.width) / CGFloat(dimensions.height)
    }
}
