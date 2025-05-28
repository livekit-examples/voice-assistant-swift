//
//  LocalParticipantView.swift
//  VoiceAssistant
//
//  Created by Blaze Pankowski on 23/05/2025.
//

import LiveKitComponents

struct LocalParticipantView: View {
    @Environment(AppViewModel.self) private var viewModel
    var namespace: Namespace.ID

    var body: some View {
        if let cameraTrack = viewModel.cameraTrack {
            ParticipantView(showInformation: false)
                .environmentObject(viewModel.localParticipant)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .aspectRatio(cameraTrack.aspectRatio, contentMode: .fit)
                .shadow(radius: 20, y: 10)
                .matchedGeometryEffect(id: "local", in: namespace)
        }
    }
}

extension VideoTrack {
    var aspectRatio: CGFloat {
        guard let dimensions else { return 1 }
        return CGFloat(dimensions.width) / CGFloat(dimensions.height)
    }
}
