//
//  ControlBar.swift
//  VoiceAssistant
//
//  Created by Blaze Pankowski on 23/05/2025.
//

import LiveKitComponents

struct ControlBar: View {
    @Environment(AppViewModel.self) private var viewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private enum Constants {
        static let buttonWidth: CGFloat = 16 * .grid
        static let buttonHeight: CGFloat = 11 * .grid
    }

    var body: some View {
        HStack(spacing: .zero) {
            biggerSpacer()
            audioControls()
            flexibleSpacer()
            videoControls()
            flexibleSpacer()
            screenShareButton()
            flexibleSpacer()
            textInputButton()
            flexibleSpacer()
            disconnectButton()
            biggerSpacer()
        }
        .buttonStyle(
            ControlBarButtonStyle(
                foregroundColor: .fg1,
                backgroundColor: .bg2,
                borderColor: .separator1
            )
        )
        .font(.system(size: 17, weight: .medium))
        .frame(height: 15 * .grid)
        .overlay(
            RoundedRectangle(cornerRadius: 7.5 * .grid)
                .stroke(.separator1, lineWidth: 1)
        )
        .background(
            RoundedRectangle(cornerRadius: 7.5 * .grid)
                .fill(.bg1)
                .shadow(color: .black.opacity(0.1), radius: 10, y: 10)
        )
        .safeAreaPadding(.bottom, 8 * .grid)
        .safeAreaPadding(.horizontal, 16 * .grid)
    }

    @ViewBuilder
    private func flexibleSpacer() -> some View {
        Spacer()
            .frame(maxWidth: horizontalSizeClass == .regular ? 8 * .grid : 2 * .grid)
    }

    @ViewBuilder
    private func biggerSpacer() -> some View {
        Spacer()
            .frame(maxWidth: horizontalSizeClass == .regular ? 8 * .grid : .infinity)
    }

    @ViewBuilder
    private func separator() -> some View {
        Rectangle()
            .fill(.separator1)
            .frame(width: 1, height: 3 * .grid)
    }

    @ViewBuilder
    private func audioControls() -> some View {
        HStack(spacing: 2 * .grid) {
            Spacer()
            AsyncButton(action: viewModel.toggleMicrophone) {
                HStack(spacing: .grid) {
                    Image(systemName: viewModel.isMicrophoneEnabled ? "microphone.fill" : "microphone.slash.fill")
                    BarAudioVisualizer(audioTrack: viewModel.audioTrack, barColor: .fg1, barCount: 3, barSpacingFactor: 0.1)
                        .frame(width: 2 * .grid, height: 0.5 * Constants.buttonHeight)
                        .frame(maxHeight: .infinity)
                        .id(viewModel.audioTrack?.id)
                }
                .frame(height: Constants.buttonHeight)
            }
            #if os(macOS)
            separator()
            AudioDeviceSelector()
                .frame(height: Constants.buttonHeight)
            #endif
            Spacer()
        }
        .frame(width: Constants.buttonWidth)
    }

    @ViewBuilder
    private func videoControls() -> some View {
        HStack(spacing: 2 * .grid) {
            Spacer()
            AsyncButton(action: viewModel.toggleCamera) {
                Image(systemName: viewModel.isCameraEnabled ? "video.fill" : "video.slash.fill")
                    .frame(height: Constants.buttonHeight)
            }
            #if os(macOS)
            separator()
            VideoDeviceSelector()
                .frame(height: Constants.buttonHeight)
            #endif
            Spacer()
        }
        .frame(width: Constants.buttonWidth)
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
                foregroundColor: .fgSerious,
                backgroundColor: .bgSerious,
                borderColor: .separatorSerious
            )
        )
    }
}

#Preview {
    ControlBar()
        .environment(AppViewModel())
}
