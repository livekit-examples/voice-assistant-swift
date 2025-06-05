import SwiftUI

struct VoiceInteractionView: View {
    @Environment(AppViewModel.self) private var viewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        if horizontalSizeClass == .regular {
            HStack {
                Spacer()
                    .frame(width: 50 * .grid)
                AgentParticipantView()
                VStack {
                    Spacer()
                    ScreenShareView()
                    LocalParticipantView()
                }
                .frame(width: 50 * .grid)
                .safeAreaPadding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ZStack(alignment: .bottom) {
                AgentParticipantView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                HStack {
                    Spacer()
                    ScreenShareView()
                    LocalParticipantView()
                }
                .frame(height: 50 * .grid)
                .safeAreaPadding()
            }
        }
    }
}
