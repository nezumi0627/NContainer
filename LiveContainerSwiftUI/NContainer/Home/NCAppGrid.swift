import SwiftUI

struct NCAppGrid: View {
    @EnvironmentObject private var sharedModel: SharedModel
    @AppStorage("darkModeIcon") private var darkModeIcon = false
    @State private var settingsApp: LCAppModel?
    @State private var showSettings = false

    private let columns = [GridItem(.adaptive(minimum: 82, maximum: 110), spacing: 22)]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 24) {
            ForEach(sharedModel.apps, id: \.self) { app in
                VStack(spacing: 4) {
                    NCAppIconView(app: app, darkModeIcon: darkModeIcon)
                        .contentShape(Rectangle())
                        .onTapGesture { launch(app) }
                    Button {
                        settingsApp = app
                        showSettings = true
                    } label: {
                        Label("App Settings", systemImage: "gearshape")
                            .labelStyle(.iconOnly)
                            .font(.caption)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("App Settings")
                }
                .contextMenu {
                    Button { launch(app) } label: {
                        Label("Launch", systemImage: "play.fill")
                    }
                    Button {
                        settingsApp = app
                        showSettings = true
                    } label: {
                        Label("App Settings", systemImage: "gearshape")
                    }
                }
            }
        }
        .padding(.horizontal)
        .sheet(isPresented: $showSettings) {
            if let settingsApp {
                NavigationView {
                    LCAppSettingsView(model: settingsApp)
                        .navigationTitle("App Settings")
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
    }

    private func launch(_ app: LCAppModel) {
        Task {
            do { try await app.runApp() }
            catch { print("NContainer launch failed: \(error)") }
        }
    }
}
