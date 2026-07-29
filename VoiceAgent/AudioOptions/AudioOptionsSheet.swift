import LiveKit
import SwiftUI

/// A minimal panel with audio options, shared between the start screen
/// and the in-call microphone menu.
///
/// The selection takes effect on Apply, not while changing the picker.
struct AudioOptionsSheet: View {
    @EnvironmentObject private var audioOptions: AudioOptions
    @Environment(\.dismiss) private var dismiss

    @State private var selectedMode: VoiceProcessingMode = .automatic

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("audio.mode.title", selection: $selectedMode) {
                        Text("audio.mode.automatic").tag(VoiceProcessingMode.automatic)
                        Text("audio.mode.platform").tag(VoiceProcessingMode.platform)
                        Text("audio.mode.software").tag(VoiceProcessingMode.software)
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                } header: {
                    Text("audio.mode.title")
                } footer: {
                    VStack(alignment: .leading, spacing: .grid) {
                        Text(modeDescription)
                        if let error = audioOptions.applyError {
                            Text(error.localizedDescription)
                                .foregroundStyle(.fgSerious)
                        }
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("audio.title")
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("audio.close") { dismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("audio.apply") { audioOptions.apply(selectedMode) }
                    }
                }
                .onAppear { selectedMode = audioOptions.voiceProcessingMode }
        }
        #if os(macOS)
        .frame(minWidth: 105 * .grid, minHeight: 45 * .grid)
        #endif
        .presentationDetents([.medium])
    }

    private var modeDescription: LocalizedStringKey {
        switch selectedMode {
        case .automatic: "audio.mode.automatic.description"
        case .platform: "audio.mode.platform.description"
        case .software: "audio.mode.software.description"
        }
    }
}
