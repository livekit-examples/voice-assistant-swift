import MarkdownUI
import SwiftUI

struct ChatView: View {
    @Environment(ChatViewModel.self) private var viewModel
    @Environment(\.colorScheme) private var colorScheme
    
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
                userTranscript(text, dark: colorScheme == .dark)
            case let .agentTranscript(markdown) where message.id == viewModel.messages.keys.last:
                agentTranscript(markdown)
            case let .agentTranscript(markdown):
                agentTranscript(markdown).opacity(0.8)
            }
        }
        .transition(.blurReplace)
    }

    @ViewBuilder
    private func userTranscript(_ text: String, dark: Bool) -> some View {
        HStack {
            Spacer(minLength: 16)
            Text(text.trimmingCharacters(in: .whitespacesAndNewlines))
                .font(.system(size: 15))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.background.secondary)
                        .stroke(.separator.secondary, lineWidth: dark ? 1 : 0)
                )
        }
    }

    @ViewBuilder
    private func agentTranscript(_ markdown: MarkdownConvertible) -> some View {
        HStack {
            Markdown(markdown)
                .markdownTextStyle {
                    FontSize(20)
                }
                .markdownTextStyle(\.code) {
                    FontSize(20)
                    FontFamilyVariant(.monospaced)
                }
                .markdownBlockStyle(\.codeBlock) { configuration in
                    configuration
                        .label
                        .padding()
                        .markdownTextStyle {
                        FontSize(14)
                        FontFamilyVariant(.monospaced)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.background.secondary)
                        )
                }
            Spacer(minLength: 16)
        }
    }
}
