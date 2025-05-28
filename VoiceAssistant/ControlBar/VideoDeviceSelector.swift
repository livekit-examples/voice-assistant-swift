//
//  VideoDeviceSelector.swift
//  VoiceAssistant
//
//  Created by Blaze Pankowski on 23/05/2025.
//

import AVFoundation
import LiveKitComponents

struct VideoDeviceSelector: View {
    @Environment(AppViewModel.self) private var viewModel

    var body: some View {
        Menu {
            ForEach(viewModel.videoDevices, id: \.uniqueID) { device in
                AsyncButton {
                    await viewModel.select(videoDevice: device)
                } label: {
                    HStack {
                        Text(device.localizedName)
                        if device.uniqueID == viewModel.selectedVideoDevice?.uniqueID {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Image(systemName: "chevron.down")
                .frame(width: 48, height: 44)
        }
    }
}
