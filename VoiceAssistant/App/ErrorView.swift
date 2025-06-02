import LiveKit
import SwiftUI

struct ErrorView: View {
    let error: Error
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 2 * .grid) {
            HStack(spacing: 2 * .grid) {
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
        .padding(3 * .grid)
        .background(Color.bgSerious)
        .foregroundStyle(Color.fgSerious)
        .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusSmall))
        .overlay(
            RoundedRectangle(cornerRadius: .cornerRadiusSmall)
                .stroke(Color.separatorSerious, lineWidth: 1)
        )
        .safeAreaPadding(4 * .grid)
    }
}

#Preview {
    ErrorView(error: NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Sample error message"]), onDismiss: {})
}
