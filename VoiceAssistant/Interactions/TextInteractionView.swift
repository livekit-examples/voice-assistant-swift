import SwiftUI

/// A multiplatform view that shows text-specific interaction controls.
///
/// Depending on the track availability, the view will show:
/// - agent participant view
/// - local participant camera preview
/// - local participant screen share preview
///
/// Additionally, the view shows a complete chat view with text input capabilities.
struct TextInteractionView: View {
    @FocusState.Binding var isKeyboardFocused: Bool

    var body: some View {
        VStack {
            VStack {
                HStack {
                    Spacer()
                    AgentParticipantView()
                    ScreenShareView()
                    LocalParticipantView()
                    Spacer()
                }
                .frame(height: 50 * .grid)
                .safeAreaPadding()

                ChatView()
                #if os(macOS)
                    .frame(maxWidth: 128 * .grid)
                #endif
                    .blurredTop()
            }
            #if os(iOS)
            .contentShape(Rectangle())
            .onTapGesture {
                isKeyboardFocused = false
            }
            #endif

            ChatTextInputView(isKeyboardFocused: _isKeyboardFocused)
        }
    }
}
