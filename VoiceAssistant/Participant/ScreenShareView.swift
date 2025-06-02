//
//  ScreenShareView.swift
//  VoiceAssistant
//
//  Created by Blaze Pankowski on 28/05/2025.
//

import LiveKitComponents

struct ScreenShareView: View {
    @Environment(AppViewModel.self) private var viewModel
    var namespace: Namespace.ID

    var body: some View {
        if let screenShareTrack = viewModel.screenShareTrack {
            SwiftUIVideoView(screenShareTrack)
                .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusSmall))
                .aspectRatio(screenShareTrack.aspectRatio, contentMode: .fit)
                .shadow(radius: 20, y: 10)
                .matchedGeometryEffect(id: String(describing: Self.self), in: namespace)
                .transition(.scale.combined(with: .opacity))
        }
    }
}
