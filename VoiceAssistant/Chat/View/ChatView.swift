import MarkdownUI
import SwiftUI

struct ChatView: View {
    @Environment(ChatViewModel.self) private var viewModel
    @State private var scrollTo: Message.ID?

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.messages.values, content: message)
                    .scrollTargetLayout()
            }
            Spacer(minLength: 16)
        }
        .clipped()
        .defaultScrollAnchor(.bottom)
        .scrollPosition(id: $scrollTo)
        .scrollIndicators(.hidden)
        .animation(.easeOut, value: viewModel.messages.count)
        .onChange(of: viewModel.messages.values.last) {
            scrollTo = viewModel.messages.keys.last
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
            case let .agentTranscript(markdown) where message.id == viewModel.messages.keys.last:
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
    private func agentTranscript(_ markdown: MarkdownConvertible) -> some View {
        HStack {
            Markdown(markdown)
                .opacity(0.75)
            Spacer(minLength: 16)
        }
    }

    @ViewBuilder
    private func agentLastTranscript(_ markdown: MarkdownConvertible) -> some View {
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
