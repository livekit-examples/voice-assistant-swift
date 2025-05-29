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
    @State private var textShimmer = false
    var namespace: Namespace.ID

    var body: some View {
        Group {
            if let avatarCameraTrack = viewModel.avatarCameraTrack {
                SwiftUIVideoView(avatarCameraTrack)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .shadow(radius: 20, y: 10)
                    .mask(
                        Circle()
                            .frame(maxWidth: videoTransition ? .infinity : 24)
                            .scaleEffect(2)
                            .animation(.smooth(duration: 1.5), value: videoTransition)
                    )
                    .onAppear {
                        videoTransition = true
                    }
                    .onDisappear {
                        videoTransition = false
                    }
            } else if let agent = viewModel.agent, let agentAudioTrack = viewModel.agentAudioTrack {
                BarAudioVisualizer(audioTrack: agentAudioTrack, agentState: agent.agentState, barCount: 5, barSpacingFactor: 0.08)
                    .frame(maxWidth: 300, maxHeight: 200)
            } else {
                VStack {
                    BarAudioVisualizer(audioTrack: nil, agentState: .listening, barCount: 1)
                        .frame(maxWidth: 48, maxHeight: 200)
                        .transition(.scale)

                    Text("Agent is listening, start talking")
                        .font(.system(size: 15))
                        .mask(
                            LinearGradient(
                                colors: [
                                    .black.opacity(0.4),
                                    .black,
                                    .black,
                                    .black.opacity(0.4),
                                ],
                                startPoint: textShimmer ? UnitPoint(x: -1, y: 0) : UnitPoint(x: 1, y: 0),
                                endPoint: textShimmer ? UnitPoint(x: 0, y: 0) : UnitPoint(x: 2, y: 0)
                            )
                            .animation(.linear(duration: 4).repeatForever(autoreverses: true), value: textShimmer)
                        )
                        .onAppear {
                            textShimmer = true
                        }
                }
            }
        }
        .matchedGeometryEffect(id: String(describing: Self.self), in: namespace)
    }
}
