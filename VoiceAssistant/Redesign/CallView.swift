//
//  CallView.swift
//  VoiceAssistant
//
//  Created by Blaze Pankowski on 22/05/2025.
//

import LiveKitComponents

struct CallView: View {
    @Environment(AppViewModel.self) private var viewModel

    var body: some View {
        if let agent = viewModel.agent {
            ParticipantView(showInformation: false)
                .environmentObject(agent)
        } else {
            Text("No agent")
        }
    }
}

// #Preview {
//    CallView()
// }
