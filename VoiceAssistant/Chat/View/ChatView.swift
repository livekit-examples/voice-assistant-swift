import MarkdownUI
import SwiftUI

struct ChatView: View {
    @Environment(ChatViewModel.self) private var viewModel
    @State private var scrolledToLast = true
    private let last = "last"

    var body: some View {
        ScrollViewReader { proxy in
            List {
                Group {
                    ForEach(viewModel.messages.values, content: message)
                    Spacer(minLength: 16)
                        .id(last)
                        .onAppear { scrolledToLast = true }
                        .onDisappear { scrolledToLast = false }
                }
                .listRowBackground(EmptyView())
                .listRowSeparator(.hidden)
                .onChange(of: viewModel.messages.values.last) {
                    guard scrolledToLast else { return }
                    withAnimation {
                        proxy.scrollTo(last, anchor: .bottom)
                    }
                }
            }
            .listStyle(.plain)
            .scrollIndicators(.hidden)
        }
        .animation(.default, value: viewModel.messages.count)
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
