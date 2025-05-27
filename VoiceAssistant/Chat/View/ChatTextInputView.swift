import SwiftUI

struct ChatTextInputView: View {
    @Environment(ChatViewModel.self) private var chatViewModel
    @State private var messageText = ""

    var body: some View {
        HStack(spacing: 12) {
            TextField("Type a message...", text: $messageText)
                .textFieldStyle(.roundedBorder)
                .submitLabel(.send)
                .onSubmit {
                    Task {
                        await sendMessage()
                    }
                }

            AsyncButton(action: sendMessage) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
            }
            .disabled(messageText.isEmpty)
        }
    }

    private func sendMessage() async {
        guard !messageText.isEmpty else { return }
        defer { messageText = "" }
        await chatViewModel.sendMessage(messageText)
    }
}
