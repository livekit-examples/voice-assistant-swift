import SwiftUI

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
                            Text(text)
                                .foregroundColor(.blue)
                            Spacer()
                        }
                        .transition(.push(from: .leading))
                    case .userTranscript(let text):
                        HStack {
                            Spacer()
                            Text(text)
                                .foregroundColor(.green)
                        }
                        .transition(.push(from: .trailing))
                    }
                }
                .animation(.smooth, value: viewModel.messages)
                .onChange(of: viewModel.messages.count) {
                    scrolled = viewModel.messages.last?.id
                }
            }
            .scrollTargetLayout()
        }
        .scrollPosition(id: $scrolled)
    }
}
