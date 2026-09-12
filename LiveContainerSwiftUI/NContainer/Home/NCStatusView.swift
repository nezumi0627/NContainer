import SwiftUI

struct NCStatusView: View {
    @EnvironmentObject private var sharedModel: SharedModel
    @State private var expirationDate: Date?
    @State private var certificateStatus: Int?

    private var certificateReady: Bool {
        LCSharedUtils.certificatePassword() != nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("NStatus", systemImage: "checkmark.shield.fill")
                    .font(.headline)
                Spacer()
                Text("LIVE")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.green)
            }
            HStack(spacing: 14) {
                statusItem("Apps", value: "\(sharedModel.apps.count)", color: .blue)
                statusItem("Certificate", value: certificateText, color: certificateColor)
                statusItem("SideStore", value: UserDefaults.sideStoreExist() ? "Ready" : "—", color: UserDefaults.sideStoreExist() ? .green : .secondary)
            }
            if let expirationDate {
                Text("有効期限: \(expirationDate.formatted(date: .numeric, time: .shortened))")
                    .font(.caption)
                    .foregroundStyle(certificateColor)
            } else if certificateReady {
                Text("証明書の有効期限を確認中…")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .accessibilityElement(children: .combine)
        .onAppear(perform: validateCertificate)
    }

    private var certificateText: String {
        guard certificateReady else { return "Setup" }
        guard let expirationDate else { return "Checking" }
        let days = Calendar.current.dateComponents([.day], from: .now, to: expirationDate).day ?? 0
        return "\(max(0, days))d left"
    }

    private var certificateColor: Color {
        guard certificateReady else { return .orange }
        guard let expirationDate else { return .secondary }
        let days = Calendar.current.dateComponents([.day], from: .now, to: expirationDate).day ?? 0
        return days <= 7 ? .orange : .green
    }

    private func validateCertificate() {
        guard certificateReady else { return }
        LCUtils.validateCertificate { status, date, _, _ in
            DispatchQueue.main.async {
                certificateStatus = Int(status)
                expirationDate = date
            }
        }
    }

    private func statusItem(_ title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(color)
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
