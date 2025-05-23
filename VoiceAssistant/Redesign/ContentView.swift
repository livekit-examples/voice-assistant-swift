//
//  ContentView.swift
//  VoiceAssistant
//
//  Created by Blaze Pankowski on 22/05/2025.
//

import LiveKitComponents

struct LocalParticipantView: View {
    @Environment(AppViewModel.self) private var viewModel
    var namespace: Namespace.ID

    var body: some View {
        if let video = viewModel.video {
            ParticipantView(showInformation: false)
                .environmentObject(viewModel.localParticipant)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .aspectRatio(video.aspectRatio, contentMode: .fit)
                .shadow(radius: 20, y: 10)
                .matchedGeometryEffect(id: "local", in: namespace)
        }
    }
}

struct AgentParticipantView: View {
    @Environment(AppViewModel.self) private var viewModel
    var namespace: Namespace.ID

    var body: some View {
        if let agent = viewModel.agent {
            ParticipantView(showInformation: false)
                .environmentObject(agent)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(radius: 20, y: 10)
                .matchedGeometryEffect(id: "agent", in: namespace)
        } else {
            BarAudioVisualizer(audioTrack: nil, agentState: .listening)
        }
    }
}

struct TextInputView: View {
    @Environment(AppViewModel.self) private var viewModel
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
        }
        .safeAreaInset(edge: .bottom) {
            CallBar()
        }
    }
}

struct VoiceInputView: View {
    @Environment(AppViewModel.self) private var viewModel
    var namespace: Namespace.ID

    var body: some View {
        ZStack(alignment: .topTrailing) {
            AgentParticipantView(namespace: namespace)
            LocalParticipantView(namespace: namespace)
                .frame(maxWidth: 120, maxHeight: 200)
        }
        .padding(.horizontal)
        .safeAreaInset(edge: .bottom) {
            CallBar()
        }
    }
}

struct ContentView: View {
    @Environment(AppViewModel.self) private var viewModel
    @State private var chatViewModel = ChatViewModel()
    @Namespace private var transitions

    var body: some View {
        Group {
            switch (viewModel.connectionState, viewModel.inputMode) {
            case (.disconnected, _):
                StartView()
            case (.connecting, _):
                StartView()
            case (.connected, .text):
                TextInputView(namespace: transitions)
                    .environment(chatViewModel)
            case (.connected, .voice):
                VoiceInputView(namespace: transitions)
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
