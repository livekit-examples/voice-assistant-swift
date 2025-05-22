//
//  StartView.swift
//  VoiceAssistant
//
//  Created by Blaze Pankowski on 22/05/2025.
//

import SwiftUI

struct StartView: View {
    @State private var isConnecting = false
    private let error: Error? = NSError()

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

            if error != nil {
                Text("Error connecting. Make sure your agent is properly configured and try again.")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.foregroundSerious)
            }

            Spacer()
                .frame(height: 16)

            Button {
                isConnecting.toggle()
            } label: {
                HStack(spacing: 8) {
                    Spacer()
                    if isConnecting {
                        Spinner()
                            .transition(.scale.combined(with: .opacity))
                    }
                    Text(isConnecting ? "Connecting" : "Start call")
                        .textCase(.uppercase)
                        .monospaced()
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
        .animation(.easeInOut(duration: 0.2), value: isConnecting)
        #if !os(visionOS)
            .sensoryFeedback(.selection, trigger: isConnecting)
        #endif
    }
}

#Preview {
    StartView()
}
