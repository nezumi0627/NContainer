import Foundation

final class NCPluginManager {
    var pluginsDirectory: URL {
        LCPath.lcGroupDocPath.appendingPathComponent("NContainer/Plugins", isDirectory: true)
    }

    func installedPlugins() -> [NCPluginManifest] {
        let fm = FileManager.default
        try? fm.createDirectory(at: pluginsDirectory, withIntermediateDirectories: true)
        guard let urls = try? fm.contentsOfDirectory(at: pluginsDirectory, includingPropertiesForKeys: nil) else { return [] }
        return urls.compactMap { try? loadManifest(from: $0) }.sorted { $0.name < $1.name }
    }

    func install(packageURL: URL) throws {
        let manifest = try loadManifest(from: packageURL)
        let destination = pluginsDirectory.appendingPathComponent(manifest.identifier, isDirectory: true)
        let fm = FileManager.default
        try fm.createDirectory(at: pluginsDirectory, withIntermediateDirectories: true)
        if fm.fileExists(atPath: destination.path) { try fm.removeItem(at: destination) }
        try fm.copyItem(at: packageURL, to: destination)
    }

    func loadManifest(from packageURL: URL) throws -> NCPluginManifest {
        let manifestURL = packageURL.appendingPathComponent("manifest.json")
        let data = try Data(contentsOf: manifestURL)
        let manifest = try JSONDecoder().decode(NCPluginManifest.self, from: data)
        guard manifest.apiVersion <= NCPluginManifest.currentAPIVersion else {
            throw NCPluginError.unsupportedAPIVersion(manifest.apiVersion)
        }
        return manifest
    }
}
