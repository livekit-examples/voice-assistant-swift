//
//  AgentListeningView.swift
//  VoiceAssistant
//
//  Created by Blaze Pankowski on 29/05/2025.
//

import SwiftUI

struct AgentListeningView: View {
    @State private var textShimmer = false

    var body: some View {
        Text("agent.listening")
            .font(.system(size: 15))
            .mask(
                LinearGradient(
                    colors: [
                        .black.opacity(0.4),
                        .black,
                        .black,
                        .black.opacity(0.4),
                    ],
                    startPoint: textShimmer ? UnitPoint(x: -1, y: 0) : UnitPoint(x: 1, y: 0),
                    endPoint: textShimmer ? UnitPoint(x: 0, y: 0) : UnitPoint(x: 2, y: 0)
                )
                .animation(.linear(duration: 4).repeatForever(autoreverses: true), value: textShimmer)
            )
            .onAppear {
                textShimmer = true
            }
    }
}
