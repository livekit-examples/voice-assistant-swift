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
//                            Text(text)
//                                .foregroundColor(.blue)
//                                .multilineTextAlignment(.leading)
//                                .fixedSize(horizontal: false, vertical: true)
                            Markdown(text)
                            Spacer()
                        }
//                        .transition(.push(from: .leading))
                    case .userTranscript(let text):
                        HStack {
                            Spacer()
                            Markdown(text)
                        }
//                        .transition(.push(from: .trailing))
                    }
                }
                .scrollTargetLayout()
                .padding(.vertical, 12)
                .onChange(of: viewModel.messages) {
                    withAnimation(.easeOut) {
                        scrolled = viewModel.messages.last?.id
                    }
                }
            }
        }
        .scrollPosition(id: $scrolled, anchor: .bottom)
    }
}
