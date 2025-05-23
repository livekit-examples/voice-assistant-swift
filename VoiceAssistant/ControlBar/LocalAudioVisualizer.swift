//
//  LocalAudioVisualizer.swift
//  VoiceAssistant
//
//  Created by Blaze Pankowski on 23/05/2025.
//

import LiveKitComponents

struct LocalAudioVisualizer: View {
    var track: AudioTrack?

    @StateObject private var audioProcessor: AudioProcessor

    init(track: AudioTrack?) {
        self.track = track
        _audioProcessor = StateObject(
            wrappedValue: AudioProcessor(
                track: track,
                bandCount: 5,
                isCentered: false
            ))
    }

    public var body: some View {
        HStack(spacing: 3) {
            ForEach(0 ..< 5, id: \.self) { index in
                RoundedRectangle(cornerRadius: 1)
                    .fill(.primary)
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
                    .scaleEffect(
                        y: max(0.05, CGFloat(audioProcessor.bands[index])), anchor: .center
                    )
            }
        }
    }
}
