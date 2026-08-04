import LiveKit
import SwiftUI

/// A minimal panel with audio options, shared between the start screen
/// and the in-call microphone menu.
///
/// Presented as a popover, which sizes itself to this content. Dismissing
/// by tapping outside discards the selection, so there is no close button.
///
/// The selection takes effect on Apply, not while changing the picker.
struct AudioOptionsSheet: View {
    @EnvironmentObject private var audioOptions: AudioOptions
    @Environment(\.dismiss) private var dismiss

    @State private var selectedMode: VoiceProcessingMode = .automatic

    var body: some View {
        VStack(alignment: .leading, spacing: 2 * .grid) {
            Text("audio.mode.title")
                .font(.subheadline)
                .foregroundStyle(.fg3)

            Picker("audio.mode.title", selection: $selectedMode) {
                Text("audio.mode.automatic").tag(VoiceProcessingMode.automatic)
                Text("audio.mode.platform").tag(VoiceProcessingMode.platform)
                Text("audio.mode.software").tag(VoiceProcessingMode.software)
            }
            .pickerStyle(.segmented)
            .labelsHidden()

            Text(modeDescription)
                .font(.footnote)
                .foregroundStyle(.fg3)
                .fixedSize(horizontal: false, vertical: true)

            if let error = audioOptions.applyError {
                Text(error.localizedDescription)
                    .font(.footnote)
                    .foregroundStyle(.fgSerious)
                    .fixedSize(horizontal: false, vertical: true)
            }

            applyButton()
                .padding(.top, 2 * .grid)
        }
        .padding(4 * .grid)
        // A fixed width keeps the description wrapping predictable, since a
        // popover otherwise sizes itself around the widest line.
        .frame(width: 70 * .grid)
        .presentationCompactAdaptation(.popover)
        .onAppear { selectedMode = audioOptions.voiceProcessingMode }
    }

    /// Styled as the primary action, matching the start screen button.
    private func applyButton() -> some View {
        Button {
            audioOptions.apply(selectedMode)
            dismiss()
        } label: {
            HStack {
                Spacer()
                Text("audio.apply")
                Spacer()
            }
            .frame(height: 11 * .grid)
        }
        #if os(visionOS)
        .buttonStyle(.borderedProminent)
        #else
        .buttonStyle(ProminentButtonStyle())
        #endif
    }

    private var modeDescription: LocalizedStringKey {
        switch selectedMode {
        case .automatic: "audio.mode.automatic.description"
        case .platform: "audio.mode.platform.description"
        case .software: "audio.mode.software.description"
        }
    }
}
