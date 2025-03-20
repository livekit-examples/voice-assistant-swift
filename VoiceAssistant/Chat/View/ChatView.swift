import MarkdownUI
import SwiftUI

struct ChatView: View {
    @Environment(ChatViewModel.self) var viewModel
    @State var scrolled: Message.ID?

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.messages, content: messageView)
            }
            .scrollTargetLayout()
        }
        .scrollPosition(id: $scrolled)
        .scrollIndicators(.hidden)
        .animation(.smooth, value: viewModel.messages.count)
        .onChange(of: viewModel.messages.elements.last) {
            scrolled = viewModel.messages.elements.last?.id
    }
    }

    @ViewBuilder
    private func messageView(message: Message) -> some View {
        switch message.content {
        case let .userTranscript(text):
            userTranscript(text: text)
        case let .agentTranscript(text) where message.id == viewModel.messages.ids.last:
            agentLastTranscript(text: text)
        case let .agentTranscript(text):
            agentTranscript(text: text)
        }
    }

    @ViewBuilder
    private func userTranscript(text: String) -> some View {
        HStack {
            Spacer()
            Text(text)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.background.secondary)
                )
                .shadow(color: .black.opacity(0.1), radius: 5, x: 5, y: 5)
                .padding(.horizontal)
        }
    }

    @ViewBuilder
    private func agentTranscript(text: String) -> some View {
        HStack {
            Markdown(text)
            Spacer()
        }
    }

    @ViewBuilder
    private func agentLastTranscript(text: String) -> some View {
        HStack {
            Markdown(text)
                .markdownTextStyle {
                    FontSize(28)
                }
            Spacer()
        }
    }
}
