import SwiftUI

struct VoiceInteractionView: View {
    @Environment(AppViewModel.self) private var viewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    var namespace: Namespace.ID

    var body: some View {
        if horizontalSizeClass == .regular {
            HStack {
                Spacer()
                    .frame(width: 50 * .grid)
                AgentParticipantView(namespace: namespace)
                VStack {
                    Spacer()
                    ScreenShareView(namespace: namespace)
                    LocalParticipantView(namespace: namespace)
                }
                .frame(width: 50 * .grid)
                .safeAreaPadding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ZStack(alignment: .bottom) {
                AgentParticipantView(namespace: namespace)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                HStack {
                    Spacer()
                    ScreenShareView(namespace: namespace)
                    LocalParticipantView(namespace: namespace)
                }
                .frame(height: 50 * .grid)
                .safeAreaPadding()
            }
        }
    }
}
