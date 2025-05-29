//
//  ButtonStyle.swift
//  VoiceAssistant
//
//  Created by Blaze Pankowski on 29/05/2025.
//

import SwiftUI

struct StartButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .textCase(.uppercase)
            .font(.system(size: 14, weight: .semibold, design: .monospaced))
            .foregroundStyle(Color.white)
            .background(Color.blue500.opacity(configuration.isPressed ? 0.75 : 1))
            .cornerRadius(8)
    }
}
