import SwiftUI

extension CGFloat {
    static let grid: Self = 4

    static let cornerRadiusSmall: Self = 2 * grid
    static let cornerRadiusLarge: Self = 4 * grid
}

struct ProminentButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .textCase(.uppercase)
            .font(.system(size: 14, weight: .semibold, design: .monospaced))
            .foregroundStyle(Color.white)
            .background(Color.fgAccent.opacity(configuration.isPressed ? 0.75 : 1))
            .cornerRadius(8)
    }
}

struct RoundButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(.white)
            .background(isEnabled ? .fgAccent.opacity(configuration.isPressed ? 0.75 : 1) : .fg4)
            .clipShape(Circle())
    }
}

struct ControlBarButtonStyle: ButtonStyle {
    var isToggled: Bool = false
    let foregroundColor: Color
    let backgroundColor: Color
    let borderColor: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .medium))
            .foregroundStyle(configuration.isPressed ? foregroundColor.opacity(0.75) : foregroundColor)
            .background(
                RoundedRectangle(cornerRadius: .cornerRadiusSmall)
                    .fill(isToggled ? backgroundColor : .clear)
            )
    }
}
