import SwiftUI

struct NCAppIconView: View {
    @ObservedObject var app: LCAppModel
    let darkModeIcon: Bool

    var body: some View {
        VStack(spacing: 6) {
            IconImageView(icon: app.appInfo.iconIsDarkIcon(darkModeIcon) ?? UIImage())
                .frame(width: 64, height: 64)
                .accessibilityHidden(true)
            Text(app.displayName)
                .font(.caption)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 82)
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(app.displayName)
    }
}
