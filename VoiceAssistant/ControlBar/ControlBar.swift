//
//  ControlBar.swift
//  VoiceAssistant
//
//  Created by Blaze Pankowski on 23/05/2025.
//

import SwiftUI

struct ControlBar: View {
    @Environment(AppViewModel.self) private var viewModel

    enum Constants {
        static let buttonWidth = 62.0
        static let buttonHeight = 44.0
    }

    var body: some View {
        HStack {
            AsyncButton(action: viewModel.toggleMute) {
                HStack(spacing: 8) {
                    Image(systemName: viewModel.isMuted ? "microphone.slash.fill" : "microphone.fill")
                    LocalAudioVisualizer(track: viewModel.localParticipant.firstAudioTrack)
                }
                .padding(.leading, 16)
            }
            .frame(height: Constants.buttonHeight)

            #if os(macOS)
            AudioDeviceSelector()
                .frame(height: Constants.buttonHeight)
            #endif

            AsyncButton(action: viewModel.toggleVideo) {
                Image(systemName: viewModel.isVideoEnabled ? "video.fill" : "video.slash.fill")
                    .frame(width: Constants.buttonWidth, height: Constants.buttonHeight)
            }
            .frame(width: Constants.buttonWidth, height: Constants.buttonHeight)

            AsyncButton {} label: {
                Image(systemName: "arrow.up.square.fill")
                    .frame(width: Constants.buttonWidth, height: Constants.buttonHeight)
            }
            .frame(width: Constants.buttonWidth, height: Constants.buttonHeight)

            AsyncButton(action: viewModel.enterTextInputMode) {
                Image(systemName: "ellipsis.message.fill")
                    .frame(width: Constants.buttonWidth, height: Constants.buttonHeight)
            }
            .frame(width: Constants.buttonWidth, height: Constants.buttonHeight)

            Rectangle()
                .fill(.separator1)
                .frame(width: 1, height: Constants.buttonHeight)

            AsyncButton(action: viewModel.disconnect) {
                Image(systemName: "phone.down.fill")
                    .frame(width: Constants.buttonWidth, height: Constants.buttonHeight)
            }
            .frame(width: Constants.buttonWidth, height: Constants.buttonHeight)
            .buttonStyle(CallBarButtonStyle(foregroundColor: .foregroundSerious, backgroundColor: .backgroundSerious, borderColor: .separatorSerious))
        }
        .buttonStyle(CallBarButtonStyle(
            foregroundColor: .foreground1,
            backgroundColor: .background2,
            borderColor: .separator1
        ))
        .backgroundStyle(Color.background1)
        .frame(height: 60)
        .shadow(color: .black.opacity(0.1), radius: 20)
        .overlay(
            RoundedRectangle(cornerRadius: 30)
                .stroke(.separator1, lineWidth: 1)
        )
    }
}

struct CallBarButtonStyle: ButtonStyle {
    let foregroundColor: Color
    let backgroundColor: Color
    let borderColor: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .medium))
            .foregroundStyle(configuration.isPressed ? foregroundColor.opacity(0.5) : foregroundColor)
//            .background(
//                RoundedRectangle(cornerRadius: 8)
//                    .fill(configuration.isPressed ? backgroundColor.opacity(0.5) : backgroundColor)
//            )
//            .overlay(
//                RoundedRectangle(cornerRadius: 8)
//                    .stroke(configuration.isPressed ? borderColor.opacity(0.5) : borderColor, lineWidth: 1)
//            )
    }
}

#Preview {
    ControlBar()
        .environment(AppViewModel())
}
