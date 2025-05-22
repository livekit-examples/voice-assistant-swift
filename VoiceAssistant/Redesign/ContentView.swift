//
//  ContentView.swift
//  VoiceAssistant
//
//  Created by Blaze Pankowski on 22/05/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = AppViewModel()

    var body: some View {
        Group {
            switch viewModel.state.connectionState {
            case .disconnected:
                StartView()
            case .connecting where !viewModel.state.isListening:
                StartView()
            case .connected:
                ChatView()
                    .environment(ChatViewModel(room: viewModel.room, messageReceivers: TranscriptionStreamReceiver(room: viewModel.room)))
            default:
                Text("\(viewModel.state.connectionState)")
            }
        }
        .environment(viewModel)
        .animation(.default, value: viewModel.state.connectionState)
    }
}

#Preview {
    ContentView()
}
