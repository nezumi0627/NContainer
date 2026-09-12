import SwiftUI

struct NCBetaSettingsView: View {
    @State private var values: [NCBetaFeature: Bool] = Dictionary(
        uniqueKeysWithValues: NCBetaFeature.allCases.map { ($0, NCBetaFeatures.isEnabled($0)) }
    )
    @AppStorage(NCBetaFeatures.disableLiquidGlassKey) private var disableLiquidGlass = false

    var body: some View {
        Form {
            Section {
                Toggle(isOn: $disableLiquidGlass) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Disable Liquid Glass")
                        Text("NContainerと起動したアプリのLiquid Glassを無効化します。")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            } header: {
                Text("Appearance")
            }
            Section {
                ForEach(NCBetaFeature.allCases) { feature in
                    Toggle(isOn: binding(for: feature)) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(feature.title)
                            Text(feature.description)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            } header: {
                Text("Beta Features")
            } footer: {
                Text("Beta 機能は個別に無効化できます。問題が起きた場合はすべて無効化してください。")
            }

            Section {
                Button(role: .destructive) {
                    NCBetaFeatures.disableAll()
                    values = Dictionary(uniqueKeysWithValues: NCBetaFeature.allCases.map { ($0, false) })
                } label: {
                    Label("Disable All Beta Features", systemImage: "exclamationmark.triangle")
                }
            }
        }
        .navigationTitle("NContainer Beta Lab")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func binding(for feature: NCBetaFeature) -> Binding<Bool> {
        Binding(
            get: { values[feature] ?? false },
            set: {
                values[feature] = $0
                NCBetaFeatures.setEnabled($0, for: feature)
            }
        )
    }
}
