//
//  CallView.swift
//  VoiceAssistant
//
//  Created by Blaze Pankowski on 22/05/2025.
//

import LiveKitComponents

struct CallView: View {
    @Environment(AppViewModel.self) private var viewModel
    @State private var chatViewModel = ChatViewModel()

    var body: some View {
        if let agent = viewModel.state.agent {
            ParticipantView(showInformation: false)
                .environmentObject(agent)
        } else {
            Text("No agent")
        }

        ChatView()
            .environment(chatViewModel)
    }
}

// #Preview {
//    CallView()
// }
