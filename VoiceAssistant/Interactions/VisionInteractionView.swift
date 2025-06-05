import SwiftUI

#if os(visionOS)
struct VisionInteractionView: View {
    @Environment(AppViewModel.self) private var viewModel
    @Environment(ChatViewModel.self) private var chatViewModel

    var body: some View {
        HStack {
            VStack {
                Spacer()
                ScreenShareView(namespace: namespace)
                LocalParticipantView(namespace: namespace)
                Spacer()
            }
            .frame(width: 125 * .grid)
            AgentParticipantView(namespace: namespace)
                .frame(width: 175 * .grid)
                .frame(maxHeight: .infinity)
                .glassBackgroundEffect()
            VStack {
                if case .text = viewModel.interactionMode {
                    ChatView()
                    ChatTextInputView()
                }
            }
            .frame(width: 125 * .grid)
            .glassBackgroundEffect()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
#endif
