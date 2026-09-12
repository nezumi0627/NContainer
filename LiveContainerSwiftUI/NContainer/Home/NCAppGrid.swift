import SwiftUI

struct NCAppGrid: View {
    @EnvironmentObject private var sharedModel: SharedModel
    @AppStorage("darkModeIcon") private var darkModeIcon = false

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
                    }
            }
        }
        .padding(.horizontal)
    }

    private func launch(_ app: LCAppModel) {
        Task {
            do { try await app.runApp() }
            catch { print("NContainer launch failed: \(error)") }
        }
    }
}
