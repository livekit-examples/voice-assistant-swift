import SwiftUI

struct VoiceInteractionView: View {
    @Environment(AppViewModel.self) private var viewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    var namespace: Namespace.ID

    var body: some View {
        if horizontalSizeClass == .regular {
            HStack(alignment: .bottom) {
                AgentParticipantView(namespace: namespace)
                VStack {
                    ScreenShareView(namespace: namespace)
                        .frame(maxWidth: 50 * .grid, maxHeight: 50 * .grid)
                    LocalParticipantView(namespace: namespace)
                        .frame(maxWidth: 50 * .grid, maxHeight: 50 * .grid)
                }
            }
        } else {
            ZStack(alignment: .bottom) {
                AgentParticipantView(namespace: namespace)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                HStack {
                    Spacer()
                        .frame(maxWidth: .infinity)
                    ScreenShareView(namespace: namespace)
                        .frame(maxWidth: 50 * .grid, maxHeight: 50 * .grid)
                    LocalParticipantView(namespace: namespace)
                        .frame(maxWidth: 50 * .grid, maxHeight: 50 * .grid)
                }
                .padding()
            }
        }
    }
}
