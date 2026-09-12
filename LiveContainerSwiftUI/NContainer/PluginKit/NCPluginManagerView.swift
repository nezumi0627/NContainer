import SwiftUI
import UniformTypeIdentifiers

struct NCPluginManagerView: View {
    @State private var plugins: [NCPluginManifest] = []
    @State private var importing = false
    @State private var errorMessage: String?

    var body: some View {
        List {
            if plugins.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "puzzlepiece.extension")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("No Plugins").font(.headline)
                    Text("manifest.jsonを含むプラグインフォルダを追加できます。")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 48)
            } else {
                ForEach(plugins, id: \.identifier) { plugin in
                    VStack(alignment: .leading, spacing: 3) {
                        Text(plugin.name).font(.headline)
                        Text("v\(plugin.version) • API \(plugin.apiVersion)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Plugin Manager")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add", systemImage: "plus") { importing = true }
            }
        }
        .onAppear(perform: reload)
        .fileImporter(isPresented: $importing, allowedContentTypes: [.folder], allowsMultipleSelection: false) { result in
            do {
                guard let url = try result.get().first else { return }
                let secured = url.startAccessingSecurityScopedResource()
                defer { if secured { url.stopAccessingSecurityScopedResource() } }
                try NCManager.shared.plugins.install(packageURL: url)
                reload()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
        .alert("Plugin Manager", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
            Button("OK", role: .cancel) { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private func reload() {
        plugins = NCManager.shared.plugins.installedPlugins()
    }
}
