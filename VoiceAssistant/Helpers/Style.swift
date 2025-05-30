//
//  Style.swift
//  VoiceAssistant
//
//  Created by Blaze Pankowski on 29/05/2025.
//

import SwiftUI

extension CGFloat {
    static let grid: Self = 4
    static let defaultCornerRadius: Self = 2 * grid
}

struct ProminentButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .textCase(.uppercase)
            .font(.system(size: 14, weight: .semibold, design: .monospaced))
            .foregroundStyle(Color.white)
            .background(Color.blue500.opacity(configuration.isPressed ? 0.75 : 1))
            .cornerRadius(8)
    }
}

struct ControlBarButtonStyle: ButtonStyle {
    var isToggled: Bool = false
    let foregroundColor: Color
    let backgroundColor: Color
    let borderColor: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .medium))
            .foregroundStyle(configuration.isPressed ? foregroundColor.opacity(0.5) : foregroundColor)
            .background(
                RoundedRectangle(cornerRadius: .defaultCornerRadius)
                    .fill(isToggled ? backgroundColor : .clear)
            )
    }
}
