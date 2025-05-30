//
//  StartView.swift
//  VoiceAssistant
//
//  Created by Blaze Pankowski on 22/05/2025.
//

import SwiftUI

struct StartView: View {
    @Environment(AppViewModel.self) private var viewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "apple.terminal")
                .font(.system(size: 56, weight: .thin))
            Text("connect.tip")
                .font(.system(size: 17))
                .tint(.secondary) // for markdown links

            Spacer()
                .frame(height: 32)

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
            .buttonStyle(ProminentButtonStyle())
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, horizontalSizeClass == .regular ? 128 : 64)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    StartView()
        .environment(AppViewModel())
}
