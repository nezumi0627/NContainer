import SwiftUI

struct NCDockView: View {
    @EnvironmentObject private var sharedModel: SharedModel

    var body: some View {
        HStack(spacing: 22) {
            Image(systemName: "square.grid.2x2")
            Text("NContainer")
                .font(.footnote.weight(.semibold))
            Spacer()
            Text("\(sharedModel.apps.count) apps")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(.thinMaterial, in: Capsule())
        .accessibilityElement(children: .combine)
    }
}
