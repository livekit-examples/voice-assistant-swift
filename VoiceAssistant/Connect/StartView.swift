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
                Text("\(Text("connect.tip")) \(Text("connect.link").underline()).")
                    .font(.system(size: 17))
            }
            .foregroundStyle(Color.foreground1)
            .tint(Color.foreground1)

            Spacer()
                .frame(height: 16)

            AsyncButton(action: viewModel.connect) {
                Text("connect.start")
                    .frame(width: 232, height: 44)
            } busyLabel: {
                HStack(spacing: 8) {
                    Spacer()
                    Spinner()
                    Text("connect.connecting")
                    Spacer()
                }
                .frame(width: 232, height: 44)
            }
            .buttonStyle(StartButtonStyle())
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 64)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        #if !os(visionOS)
            .sensoryFeedback(.impact, trigger: viewModel.connectionState == .connecting)
        #endif
    }
}

#Preview {
    StartView()
        .environment(AppViewModel())
}
