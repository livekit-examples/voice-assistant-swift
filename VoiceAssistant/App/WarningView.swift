import SwiftUI

struct WarningView: View {
    let warning: LocalizedStringKey

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle")
                Text("warning.title")
                    .font(.system(size: 15, weight: .semibold))
                Spacer()
            }

            Text(warning)
                .font(.system(size: 15))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .foregroundStyle(Color.foregroundModerate)
        .background(Color.backgroundModerate)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.separatorModerate, lineWidth: 1)
        )
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}

#Preview {
    WarningView(warning: "Sample warning message")
}
