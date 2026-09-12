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
                NCAppIconView(app: app, darkModeIcon: darkModeIcon)
                    .onTapGesture { launch(app) }
                    .contextMenu {
                        Button { launch(app) } label: {
                            Label("Launch", systemImage: "play.fill")
                        }
                        NavigationLink {
                            LCAppSettingsView(model: app)
                        } label: {
                            Label("App Settings", systemImage: "gearshape")
                        }
                        Button {
                            settingsApp = app
                            showSettings = true
                        } label: {
                            Label("Open App Settings", systemImage: "slider.horizontal.3")
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
