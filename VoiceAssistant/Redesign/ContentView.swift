//
//  ContentView.swift
//  VoiceAssistant
//
//  Created by Blaze Pankowski on 22/05/2025.
//

import SwiftUI

struct ContentView: View {
    @Environment(AppViewModel.self) private var viewModel

    var body: some View {
        Group {
            switch viewModel.state.connectionState {
            case .disconnected:
                StartView()
            case .connecting where !viewModel.state.isListening:
                StartView()
            case .connecting, .connected, .reconnecting:
                CallView()
            }
        }
        .animation(.default, value: viewModel.state.connectionState)
    }
}

#Preview {
    ContentView()
}
