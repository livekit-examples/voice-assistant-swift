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

            if viewModel.state.error != nil {
                Text("Error connecting. Make sure your agent is properly configured and try again.")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.foregroundSerious)
            }

            Spacer()
                .frame(height: 16)

            Button {
                viewModel.connect()
            } label: {
                HStack(spacing: 8) {
                    Spacer()
                    if viewModel.state.connectionState == .connecting {
                        Spinner()
                            .transition(.scale.combined(with: .opacity))
                    }
                    Text(viewModel.state.connectionState == .connecting ? "Connecting" : "Start call")
                        .textCase(.uppercase)
                        .monospaced()
                        .foregroundStyle(Color.white)
                        .font(.system(size: 14, weight: .semibold))
                        .frame(maxHeight: .infinity)
                    Spacer()
                }
                .background(.blue500)
                .cornerRadius(8)
                .frame(height: 44)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)
            }
            .buttonStyle(.plain)
            .tint(Color.blue500)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 64)
//        .animation(.easeInOut(duration: 0.2), value: viewModel.connectionState)
//        #if !os(visionOS)
//        .sensoryFeedback(.selection, trigger: viewModel.state.isConnecting)
//        #endif
    }
}

#Preview {
    StartView()
}
