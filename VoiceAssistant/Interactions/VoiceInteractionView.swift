//
//  VoiceInteractionView.swift
//  VoiceAssistant
//
//  Created by Blaze Pankowski on 23/05/2025.
//

import SwiftUI

struct VoiceInteractionView: View {
    @Environment(AppViewModel.self) private var viewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    var namespace: Namespace.ID

    var body: some View {
        Group {
            if horizontalSizeClass == .regular {
                ZStack(alignment: .bottomTrailing) {
                    AgentParticipantView(namespace: namespace)
                        .frame(maxWidth: .infinity)
                        .ignoresSafeArea()
                    VStack {
                        ScreenShareView(namespace: namespace)
                            .frame(maxWidth: 200, maxHeight: 200)
                        LocalParticipantView(namespace: namespace)
                            .frame(maxWidth: 200, maxHeight: 200)
                    }
                }
            } else {
                ZStack(alignment: .topTrailing) {
                    AgentParticipantView(namespace: namespace)
                    HStack {
                        LocalParticipantView(namespace: namespace)
                            .frame(maxWidth: 120, maxHeight: 200)
                        ScreenShareView(namespace: namespace)
                            .frame(maxWidth: 200, maxHeight: 200)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaInset(edge: .bottom) {
            ControlBar()
        }
    }
}
