import SwiftUI
import MarkdownUI

struct ChatView: View {
    @Environment(ChatViewModel.self) var viewModel
    @State var scrolled: Message.ID?
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(viewModel.messages) { message in
                    switch message.content {
                    case .agentTranscript(let text):
                        HStack {
                            Markdown(text)
                                .markdownTextStyle {
                                    if message.id == viewModel.messages.ids.last {
                                        ForegroundColor(.purple)
                                    }
                                }
                            Spacer()
                        }
                        .padding(.vertical, 12)
                    case .userTranscript(let text):
                        HStack {
                            Spacer()
                            Markdown(text)
                        }
                        .padding(.vertical, 12)
                    }
                }
                .onChange(of: viewModel.messages.elements.last?.content) {
                    withAnimation(.bouncy) {
                        scrolled = viewModel.messages.ids.last
                    }
                }
                .scrollTargetLayout()
            }

        }
        .scrollPosition(id: $scrolled, anchor: .bottom)
    }
}
