import LiveKitComponents

struct LocalParticipantView: View {
    @Environment(AppViewModel.self) private var viewModel
    var namespace: Namespace.ID

    var body: some View {
        if let cameraTrack = viewModel.cameraTrack {
            SwiftUIVideoView(cameraTrack)
                .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusSmall))
                .aspectRatio(cameraTrack.aspectRatio, contentMode: .fit)
                .shadow(radius: 20, y: 10)
                .transition(.scale.combined(with: .opacity))
                .overlay(alignment: .bottomTrailing) {
                    if viewModel.canSwitchCamera {
                        AsyncButton(action: viewModel.switchCamera) {
                            Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90")
                        }
                    }
                }
                .matchedGeometryEffect(id: String(describing: Self.self), in: namespace)
        }
    }
}

extension VideoTrack {
    var aspectRatio: CGFloat {
        guard let dimensions else { return 1 }
        return CGFloat(dimensions.width) / CGFloat(dimensions.height)
    }
}
