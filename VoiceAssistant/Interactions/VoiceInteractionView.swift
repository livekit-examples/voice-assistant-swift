//
//  VoiceInteractionView.swift
//  VoiceAssistant
//
//  Created by Blaze Pankowski on 23/05/2025.
//

import SwiftUI

struct VoiceInteractionView: View {
    @Environment(AppViewModel.self) private var viewModel
    var namespace: Namespace.ID

    var body: some View {
        ZStack(alignment: .topTrailing) {
            AgentParticipantView(namespace: namespace)
            HStack {
                LocalParticipantView(namespace: namespace)
                    .frame(maxWidth: 120, maxHeight: 200)
                ScreenShareView(namespace: namespace)
                    .frame(maxWidth: 200, maxHeight: 200)
            }
        }
        .padding(.horizontal)
        .safeAreaInset(edge: .bottom) {
            ControlBar()
        }
    }
}
