import SwiftUI

#if os(visionOS)
/// A platform-specific view that shows all interaction controls with optional chat.
struct VisionInteractionView: View {
    @Environment(AppViewModel.self) private var viewModel

    var body: some View {
        HStack {
            VStack {
                Spacer()
                ScreenShareView()
                LocalParticipantView()
                Spacer()
            }
            .frame(width: 125 * .grid)
            AgentParticipantView()
                .frame(width: 175 * .grid)
                .frame(maxHeight: .infinity)
                .glassBackgroundEffect()

            if case .text = viewModel.interactionMode {
                VStack {
                    ChatView()
                    ChatTextInputView()
                }
                .frame(width: 125 * .grid)
                .glassBackgroundEffect()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
#endif
