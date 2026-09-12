import Foundation

final class NCPluginManager {
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
