import LiveKit
import SwiftUI

struct ErrorView: View {
    let error: Error
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Group {
                    Image(systemName: "exclamationmark.triangle")
                    Text("error.title")
                }
                .font(.system(size: 15, weight: .semibold))

                Spacer()
                Button {
                    onDismiss()
                } label: {
                    Image(systemName: "xmark")
                }
                .buttonStyle(.plain)
            }

            Text(error.localizedDescription)
                .font(.system(size: 15))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .background(Color.backgroundSerious)
        .foregroundStyle(Color.foregroundSerious)
        .clipShape(RoundedRectangle(cornerRadius: .defaultCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: .defaultCornerRadius)
                .stroke(Color.separatorSerious, lineWidth: 1)
        )
        .padding(16)
    }
}

#Preview {
    ErrorView(error: NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Sample error message"]), onDismiss: {})
}
