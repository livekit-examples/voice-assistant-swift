import SwiftUI

struct ErrorView: View {
    let error: Error
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundStyle(Color.foregroundSerious)
                Text("Error")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.foregroundSerious)
                Spacer()
                Button {
                    onDismiss()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(Color.foregroundSerious)
                }
            }

            Text(error.localizedDescription)
                .font(.system(size: 15))
                .foregroundStyle(Color.foregroundSerious)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(Color.backgroundSerious)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.separatorSerious, lineWidth: 1)
        )
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}

#Preview {
    ErrorView(error: NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Sample error message"]), onDismiss: {})
}
