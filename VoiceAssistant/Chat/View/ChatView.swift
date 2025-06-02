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
                    Spacer(minLength: 4 * .grid)
                        .id(last)
                        .onAppear { scrolledToLast = true }
                        .onDisappear { scrolledToLast = false }
                }
                .listRowBackground(EmptyView())
                .listRowSeparator(.hidden)
                .onChange(of: viewModel.messages.values.last) {
                    if scrolledToLast {
                        proxy.scrollTo(last, anchor: .bottom)
                    }
                }
            }
            .onScrollGeometryChange(for: CGFloat.self) { geometry in
                geometry.visibleRect.height
            } action: { _, _ in
                proxy.scrollTo(last, anchor: .bottom)
            }
            .listStyle(.plain)
            .scrollIndicators(.hidden)
            .allowsHitTesting(false)
        }
        .animation(.default, value: viewModel.messages)
    }

    @ViewBuilder
    private func message(_ message: ReceivedMessage) -> some View {
        Group {
            switch message.content {
            case let .userTranscript(text):
                userTranscript(text)
            case let .agentTranscript(text):
                agentTranscript(text)
            }
        }
        .transition(.blurReplace)
    }

    @ViewBuilder
    private func userTranscript(_ text: String) -> some View {
        HStack {
            Spacer(minLength: 4 * .grid)
            Text(text.trimmingCharacters(in: .whitespacesAndNewlines))
                .font(.system(size: 15))
                .padding(.horizontal, 4 * .grid)
                .padding(.vertical, 2 * .grid)
                .foregroundStyle(.fg1)
                .background(
                    RoundedRectangle(cornerRadius: .cornerRadiusLarge)
                        .fill(.bg2)
                )
        }
    }

    @ViewBuilder
    private func agentTranscript(_ text: String) -> some View {
        HStack {
            Text(text.trimmingCharacters(in: .whitespacesAndNewlines))
                .font(.system(size: 20))
                .padding(.vertical, 2 * .grid)
            Spacer(minLength: 4 * .grid)
        }
    }
}
