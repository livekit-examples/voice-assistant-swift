import SwiftUI

struct StartView: View {
    @Environment(AppViewModel.self) private var viewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        VStack(spacing: 4 * .grid) {
            text()
            Spacer().frame(height: 4 * .grid)
            connectButton()
            #if targetEnvironment(simulator)
            Spacer().frame(height: 4 * .grid)
            simulator()
            #endif
        }
        .padding(.horizontal, horizontalSizeClass == .regular ? 32 * .grid : 16 * .grid)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        #if os(visionOS)
            .glassBackgroundEffect()
            .frame(maxWidth: 175 * .grid)
        #endif
    }

    @ViewBuilder
    private func text() -> some View {
        Image(systemName: "apple.terminal")
            .font(.system(size: 56, weight: .thin))
        Text("connect.tip")
            .font(.system(size: 17))
            .tint(.fg2) // for markdown links
            .multilineTextAlignment(.center)
    }

    @ViewBuilder
    private func connectButton() -> some View {
        AsyncButton(action: viewModel.connect) {
            Text("connect.start")
                .frame(width: 58 * .grid, height: 11 * .grid)
        } busyLabel: {
            HStack(spacing: 4 * .grid) {
                Spacer()
                Spinner()
                Text("connect.connecting")
                Spacer()
            }
            .frame(width: 58 * .grid, height: 11 * .grid)
        }
        #if os(visionOS)
        .buttonStyle(.borderedProminent)
        .controlSize(.extraLarge)
        #else
        .buttonStyle(ProminentButtonStyle())
        #endif
    }

    @ViewBuilder
    private func simulator() -> some View {
        Text("connect.simulator")
            .font(.system(size: 17))
            .foregroundStyle(.fgModerate)
            .multilineTextAlignment(.center)
    }
}

#Preview {
    StartView()
        .environment(AppViewModel())
}
