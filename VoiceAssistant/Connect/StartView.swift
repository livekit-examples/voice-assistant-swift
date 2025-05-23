//
//  StartView.swift
//  VoiceAssistant
//
//  Created by Blaze Pankowski on 22/05/2025.
//

import SwiftUI

struct StartView: View {
    @Environment(AppViewModel.self) private var viewModel

    var body: some View {
        VStack(spacing: 16) {
            Group {
                Image(systemName: "apple.terminal")
                    .font(.system(size: 64, weight: .thin))
                Text(
                    "Start a call to chat with your voice agent. Need help getting set up?\nCheck out the \(Text("[agent guide](https://docs.livekit.io/agents)").underline())."
                )
                .font(.system(size: 17))
            }
            .foregroundStyle(Color.foreground1)
            .tint(Color.foreground1)

            if viewModel.error != nil {
                Text("Error connecting. Make sure your agent is properly configured and try again.")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.foregroundSerious)
            }

            Spacer()
                .frame(height: 16)

            AsyncButton(action: viewModel.connect) {
                Text("Start call")
            } busyLabel: {
                HStack(spacing: 8) {
                    Spacer()
                    Spinner()
                    Text("Connecting")
                    Spacer()
                }
            }
            .buttonStyle(StartButtonStyle())
            .frame(height: 44)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 64)
        #if !os(visionOS)
            .sensoryFeedback(.impact, trigger: viewModel.connectionState == .connecting)
        #endif
    }
}

struct StartButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .textCase(.uppercase)
            .font(.system(size: 14, weight: .semibold, design: .monospaced))
            .foregroundStyle(Color.white)
            .background(Color.blue500)
            .cornerRadius(8)
            .padding(.horizontal, 24)
    }
}

#Preview {
    StartView()
}
