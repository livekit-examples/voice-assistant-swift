//
//  AgentParticipantView.swift
//  VoiceAssistant
//
//  Created by Blaze Pankowski on 23/05/2025.
//

import LiveKitComponents

struct AgentParticipantView: View {
    @Environment(AppViewModel.self) private var viewModel
    @State private var videoTransition = false
    var namespace: Namespace.ID

    var body: some View {
        Group {
            if let avatarCameraTrack = viewModel.avatarCameraTrack {
                SwiftUIVideoView(avatarCameraTrack)
                    .clipShape(RoundedRectangle(cornerRadius: .defaultCornerRadius))
                    .shadow(radius: 20, y: 10)
                    .mask(
                        GeometryReader { proxy in
                            let targetSize = max(proxy.size.width, proxy.size.height)
                            Circle()
                                .frame(width: videoTransition ? targetSize : 6 * .grid)
                                .scaleEffect(2)
                                .animation(.smooth(duration: 1.5), value: videoTransition)
                        }
                    )
                    .onAppear {
                        videoTransition = true
                    }
                    .onDisappear {
                        videoTransition = false
                    }
            } else if let agent = viewModel.agent, let agentAudioTrack = viewModel.agentAudioTrack {
                BarAudioVisualizer(audioTrack: agentAudioTrack, agentState: agent.agentState, barCount: 5, barSpacingFactor: 0.025)
                    .frame(width: 75 * .grid)
                    .frame(maxHeight: 48 * .grid)
            } else {
                VStack {
                    BarAudioVisualizer(audioTrack: nil, agentState: .listening, barCount: 1)
                        .frame(width: 12 * .grid)
                        .frame(maxHeight: 48 * .grid)
                }
            }
        }
        .matchedGeometryEffect(id: String(describing: Self.self), in: namespace)
    }
}
