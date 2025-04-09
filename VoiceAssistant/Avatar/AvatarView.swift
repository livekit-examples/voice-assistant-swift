//
//  AvatarView.swift
//  VoiceAssistant
//
//  Created by Blaze Pankowski on 09/04/2025.
//

import LiveKitComponents
import LiveKit
import SwiftUI

struct AvatarView: View {
    @EnvironmentObject private var room: Room
    
    var body: some View {
        if let agent = room.agentParticipant, !agent.videoTracks.isEmpty {
            ParticipantView(showInformation: false)
                .environmentObject(agent as Participant)
        }
    }
}

