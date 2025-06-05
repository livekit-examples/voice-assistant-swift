import LiveKitComponents

struct AgentParticipantView: View {
    @Environment(AppViewModel.self) private var viewModel
    @Environment(\.namespace) private var namespace
    @SceneStorage("videoTransition") private var videoTransition = false

    var body: some View {
        ZStack {
            if let avatarCameraTrack = viewModel.avatarCameraTrack {
                SwiftUIVideoView(avatarCameraTrack)
                    .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusPerPlatform))
                    .shadow(radius: 20, y: 10)
                    .mask(
                        GeometryReader { proxy in
                            let targetSize = max(proxy.size.width, proxy.size.height)
                            Circle()
                                .frame(width: videoTransition ? targetSize : 6 * .grid)
                                .position(x: 0.5 * proxy.size.width, y: 0.5 * proxy.size.height)
                                .scaleEffect(2)
                                .animation(.smooth(duration: 1.5), value: videoTransition)
                        }
                    )
                    .onAppear {
                        videoTransition = true
                    }
            } else if let agentAudioTrack = viewModel.agentAudioTrack {
                BarAudioVisualizer(audioTrack: agentAudioTrack,
                                   agentState: viewModel.agent?.agentState ?? .listening,
                                   barCount: 5,
                                   barSpacingFactor: 0.05,
                                   barMinOpacity: 0.1)
                    .frame(maxWidth: 75 * .grid, maxHeight: 48 * .grid)
                    .transition(.opacity)
            } else {
                BarAudioVisualizer(audioTrack: nil,
                                   agentState: .listening,
                                   barCount: 1,
                                   barMinOpacity: 0.1)
                    .frame(maxWidth: 10.5 * .grid, maxHeight: 48 * .grid)
                    .transition(.opacity)
            }
        }
        .animation(.default, value: viewModel.agentAudioTrack?.id)
        .matchedGeometryEffect(id: "agent", in: namespace)
    }
}
