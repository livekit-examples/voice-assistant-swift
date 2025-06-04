import SwiftUI

struct ChatTextInputView: View {
    @Environment(ChatViewModel.self) private var chatViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var messageText = ""

    var body: some View {
        HStack(spacing: 12) {
            TextField("message.placeholder", text: $messageText, axis: .vertical)
            #if os(visionOS)
                .textFieldStyle(.roundedBorder)
                .hoverEffectDisabled()
            #else
                .textFieldStyle(.plain)
            #endif
                .lineLimit(3)
                .submitLabel(.send)
                .onSubmit {
                    Task {
                        await sendMessage()
                    }
                }
            #if !os(visionOS)
                .foregroundStyle(.fg1)
//                .background(Color.bg2)
            #endif
                .padding()

            AsyncButton(action: sendMessage) {
                Image(systemName: "arrow.up")
                    .frame(width: 8 * .grid, height: 8 * .grid)
            }
            .padding(.trailing, 3 * .grid)
            .disabled(messageText.isEmpty)
            #if os(visionOS)
                .buttonStyle(.plain)
            #else
                .buttonStyle(RoundButtonStyle())
            #endif
        }
        .frame(minHeight: 12 * .grid)
        .frame(maxWidth: horizontalSizeClass == .regular ? 128 * .grid : 92 * .grid)
//        .background(Color.bg2)
        .clipShape(RoundedRectangle(cornerRadius: 6 * .grid))
        .safeAreaPadding(.horizontal, 4 * .grid)
        .safeAreaPadding(.bottom, 4 * .grid)
    }

    private func sendMessage() async {
        guard !messageText.isEmpty else { return }
        defer { messageText = "" }
        await chatViewModel.sendMessage(messageText)
    }
}

#Preview {
    ChatTextInputView()
        .environment(ChatViewModel())
}
