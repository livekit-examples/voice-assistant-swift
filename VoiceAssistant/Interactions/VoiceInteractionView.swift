import SwiftUI

struct VoiceInteractionView: View {
    @Environment(AppViewModel.self) private var viewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    var namespace: Namespace.ID

    var body: some View {
        Group {
            if horizontalSizeClass == .regular {
                HStack(alignment: .bottom) {
                    AgentParticipantView(namespace: namespace)
                    VStack {
                        ScreenShareView(namespace: namespace)
                            .frame(maxWidth: 200, maxHeight: 200)
                        LocalParticipantView(namespace: namespace)
                            .frame(maxWidth: 200, maxHeight: 200)
                    }
                }
            } else {
                ZStack(alignment: .topTrailing) {
                    AgentParticipantView(namespace: namespace)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .ignoresSafeArea()
                    HStack {
                        LocalParticipantView(namespace: namespace)
                            .frame(maxWidth: 120, maxHeight: 200)
                        ScreenShareView(namespace: namespace)
                            .frame(maxWidth: 200, maxHeight: 200)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}
