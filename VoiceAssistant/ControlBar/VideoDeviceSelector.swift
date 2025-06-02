import AVFoundation
import LiveKitComponents

#if os(macOS)
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
                .frame(height: 11 * .grid)
                .font(.system(size: 12, weight: .semibold))
        }
    }
}
#endif
