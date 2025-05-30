//
//  ControlBar.swift
//  VoiceAssistant
//
//  Created by Blaze Pankowski on 23/05/2025.
//

import SwiftUI

struct ControlBar: View {
    @Environment(AppViewModel.self) private var viewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private enum Constants {
        static let buttonWidth: CGFloat = 16 * .grid
        static let buttonHeight: CGFloat = 11 * .grid
    }

    var body: some View {
        HStack(spacing: .zero) {
            flexibleSpacer()
            audioControls()
            flexibleSpacer()
            videoControls()
            flexibleSpacer()
            screenShareButton()
            flexibleSpacer()
            textInputButton()
            flexibleSpacer()
            disconnectButton()
            flexibleSpacer()
        }
        .buttonStyle(
            ControlBarButtonStyle(
                foregroundColor: .foreground1,
                backgroundColor: .background2,
                borderColor: .separator1
            )
        )
        .font(.system(size: 17, weight: .medium))
        .frame(height: 15 * .grid)
        .clipShape(RoundedRectangle(cornerRadius: 7.5 * .grid))
        .overlay(
            RoundedRectangle(cornerRadius: 7.5 * .grid)
                .stroke(.separator1, lineWidth: 1)
        )
        .background()
        .shadow(color: .black.opacity(1), radius: 10, y: 10)
    }

    @ViewBuilder
    private func flexibleSpacer() -> some View {
        Spacer()
            .frame(maxWidth: horizontalSizeClass == .regular ? 8 * .grid : .zero)
    }

    @ViewBuilder
    private func audioControls() -> some View {
        Spacer()
            .frame(width: 4 * .grid)
        HStack(spacing: 2 * .grid) {
            AsyncButton(action: viewModel.toggleMicrophone) {
                HStack(spacing: 2 * .grid) {
                    Image(systemName: viewModel.isMicrophoneEnabled ? "microphone.fill" : "microphone.slash.fill")
                    LocalAudioVisualizer(track: viewModel.audioTrack)
                }
                .frame(height: Constants.buttonHeight)
            }
            #if os(macOS)
            Rectangle()
                .fill(.separator1)
                .frame(width: 1, height: 3 * .grid)
            AudioDeviceSelector()
                .frame(height: Constants.buttonHeight)
            #endif
        }
        .frame(minWidth: Constants.buttonWidth)
    }

    @ViewBuilder
    private func videoControls() -> some View {
        HStack(spacing: 2 * .grid) {
            AsyncButton(action: viewModel.toggleCamera) {
                Image(systemName: viewModel.isCameraEnabled ? "video.fill" : "video.slash.fill")
                    .frame(height: Constants.buttonHeight)
            }
            #if os(macOS)
            Rectangle()
                .fill(.separator1)
                .frame(width: 1, height: 3 * .grid)
            VideoDeviceSelector()
                .frame(height: Constants.buttonHeight)
            #endif
        }
        .frame(minWidth: Constants.buttonWidth)
    }

    @ViewBuilder
    private func screenShareButton() -> some View {
        AsyncButton(action: viewModel.toggleScreenShare) {
            Image(systemName: "arrow.up.square.fill")
                .frame(width: Constants.buttonWidth, height: Constants.buttonHeight)
        }
    }

    @ViewBuilder
    private func textInputButton() -> some View {
        AsyncButton(action: viewModel.enterTextInputMode) {
            Image(systemName: "ellipsis.message.fill")
                .frame(width: Constants.buttonWidth, height: Constants.buttonHeight)
        }
    }

    @ViewBuilder
    private func disconnectButton() -> some View {
        AsyncButton(action: viewModel.disconnect) {
            Image(systemName: "phone.down.fill")
                .frame(width: Constants.buttonWidth, height: Constants.buttonHeight)
        }
        .buttonStyle(
            ControlBarButtonStyle(
                foregroundColor: .foregroundSerious,
                backgroundColor: .backgroundSerious,
                borderColor: .separatorSerious
            )
        )
    }
}

#Preview {
    ControlBar()
        .environment(AppViewModel())
}
