import SwiftUI

struct WarningView: View {
    let warning: LocalizedStringKey

    var body: some View {
        VStack(spacing: 2 * .grid) {
            HStack(spacing: 2 * .grid) {
                Group {
                    Image(systemName: "exclamationmark.triangle")
                    Text("warning.title")
                }
                .font(.system(size: 15, weight: .semibold))
                Spacer()
            }

            Text(warning)
                .font(.system(size: 15))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(3 * .grid)
        .foregroundStyle(Color.foregroundModerate)
        .background(Color.backgroundModerate)
        .clipShape(RoundedRectangle(cornerRadius: .defaultCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: .defaultCornerRadius)
                .stroke(Color.separatorModerate, lineWidth: 1)
        )
        .padding(4 * .grid)
    }
}

#Preview {
    WarningView(warning: "Sample warning message")
}
