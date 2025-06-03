import SwiftUI

struct UpsideDown: ViewModifier {
    func body(content: Content) -> some View {
        content
            .rotationEffect(.radians(Double.pi))
            .scaleEffect(x: -1, y: 1, anchor: .center)
    }
}

extension View {
    func upsideDown() -> some View {
        modifier(UpsideDown())
    }
}
