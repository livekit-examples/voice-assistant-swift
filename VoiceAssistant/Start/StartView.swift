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
        VStack(spacing: 4 * .grid) {
            text()
            Spacer().frame(height: 4 * .grid)
            connectButton()
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, horizontalSizeClass == .regular ? 32 * .grid : 16 * .grid)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private func text() -> some View {
        Image(systemName: "apple.terminal")
            .font(.system(size: 56, weight: .thin))
        Text("connect.tip")
            .font(.system(size: 17))
            .tint(.secondary) // for markdown links
    }

    @ViewBuilder
    private func connectButton() -> some View {
        AsyncButton(action: viewModel.connect) {
            Text("connect.start")
                .frame(width: 58 * .grid, height: 11 * .grid)
        } busyLabel: {
            HStack(spacing: .grid) {
                Spacer()
                Spinner()
                Text("connect.connecting")
                Spacer()
            }
            .frame(width: 58 * .grid, height: 11 * .grid)
        }
        .buttonStyle(ProminentButtonStyle())
    }
}

#Preview {
    StartView()
        .environment(AppViewModel())
}
