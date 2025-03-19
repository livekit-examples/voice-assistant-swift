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
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                               
                            Spacer()
                        }
//                        .transition(.push(from: .leading))
                    case .userTranscript(let text):
                        HStack {
                            Spacer()
                            Text(text)
                                .foregroundColor(.green)
                                .multilineTextAlignment(.trailing)
                                .fixedSize(horizontal: false, vertical: true)
                        }
//                        .transition(.push(from: .trailing))
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
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
