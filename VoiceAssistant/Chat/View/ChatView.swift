import MarkdownUI
import SwiftUI

struct ChatView: View {
    @Environment(ChatViewModel.self) private var viewModel
    @State private var scrolled: Message.ID?

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.messages, content: message)
                    .scrollTargetLayout()
            }
            Spacer(minLength: 16)
        }
        .clipped()
        .defaultScrollAnchor(.bottom)
        .scrollPosition(id: $scrolled)
        .scrollIndicators(.hidden)
        .animation(.easeOut, value: viewModel.messages.count)
        .onChange(of: viewModel.messages.last) {
            scrolled = viewModel.messages.ids.last
        }
        .alert("Error while connecting to Chat", isPresented: .constant(viewModel.error != nil)) {
            Button("OK", role: .cancel) {}
        }
    }

    @ViewBuilder
    private func message(_ message: Message) -> some View {
        Group {
            switch message.content {
            case let .userTranscript(text):
                userTranscript(text)
            case let .agentTranscript(markdown) where message.id == viewModel.messages.ids.last:
                agentLastTranscript(markdown)
            case let .agentTranscript(markdown):
                agentTranscript(markdown)
            }
        }
        .transition(.blurReplace)
    }

    @ViewBuilder
    private func userTranscript(_ text: String) -> some View {
        HStack {
            Spacer(minLength: 16)
            Text(text.trimmingCharacters(in: .whitespacesAndNewlines))
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.background.secondary)
                )
        }
    }

    @ViewBuilder
    private func agentTranscript(_ markdown: MarkdownContent) -> some View {
        HStack {
            Markdown(markdown)
                .opacity(0.75)
            Spacer(minLength: 16)
        }
    }

    @ViewBuilder
    private func agentLastTranscript(_ markdown: MarkdownContent) -> some View {
        HStack {
            Markdown(markdown)
                .markdownTextStyle {
                    FontSize(20)
                    FontWeight(.medium)
                }
            Spacer(minLength: 16)
        }
    }
}
