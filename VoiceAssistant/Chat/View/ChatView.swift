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
        .animation(.default, value: viewModel.messages.count)
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
            case let .agentTranscript(text) where message.id == viewModel.messages.ids.last:
                agentLastTranscript(text)
            case let .agentTranscript(text):
                agentTranscript(text)
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
    private func agentTranscript(_ text: String) -> some View {
        HStack {
            Markdown(text)
                .opacity(0.75)
            Spacer(minLength: 16)
        }
    }

    @ViewBuilder
    private func agentLastTranscript(_ text: String) -> some View {
        HStack {
            Markdown(text)
                .markdownTextStyle {
                    FontSize(20)
                    FontWeight(.medium)
                }
            Spacer(minLength: 16)
        }
    }
}
