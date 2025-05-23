//
//  AgentParticipantView.swift
//  VoiceAssistant
//
//  Created by Blaze Pankowski on 23/05/2025.
//

import LiveKitComponents

struct AgentParticipantView: View {
    @Environment(AppViewModel.self) private var viewModel
    var namespace: Namespace.ID

    var body: some View {
        if let agent = viewModel.agent {
            ParticipantView(showInformation: false)
                .environmentObject(agent)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(radius: 20, y: 10)
                .matchedGeometryEffect(id: "agent", in: namespace)
        } else {
            BarAudioVisualizer(audioTrack: nil, agentState: .listening)
        }
    }
}
