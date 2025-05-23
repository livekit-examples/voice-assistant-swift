//
//  AudioDeviceSelector.swift
//  VoiceAssistant
//
//  Created by Blaze Pankowski on 23/05/2025.
//

import LiveKitComponents

struct AudioDeviceSelector2: View {
    @Environment(AppViewModel.self) private var viewModel

    var body: some View {
        Menu {
            ForEach(viewModel.audioDevices, id: \.deviceId) { device in
                Button {
                    viewModel.select(audioDevice: device)
                } label: {
                    HStack {
                        Text(device.name)
                        if device.deviceId == viewModel.selectedDevice.deviceId {
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
