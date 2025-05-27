import SwiftUI

struct ChatTextInputView: View {
    @Environment(ChatViewModel.self) private var chatViewModel
    @State private var messageText = ""

    var body: some View {
        HStack(spacing: 12) {
            TextField("Message", text: $messageText, axis: .vertical)
                .textFieldStyle(.plain)
                .lineLimit(5)
                .submitLabel(.send)
                .onSubmit {
                    Task {
                        await sendMessage()
                    }
                }
                .background(Color.background2)

            AsyncButton(action: sendMessage) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
            }
            .tint(.blue500)
            .disabled(messageText.isEmpty)
        }
        .frame(height: 48)
        .background(Color.background2)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.1), radius: 20)
        .padding(.horizontal)
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
