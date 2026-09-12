import Foundation

/// Shared entry point for NContainer-only services.
final class NCManager {
    static let shared = NCManager()

    let boot = NCBootManager()
    let plugins = NCPluginManager()
    let tweaks = NCTweakManager()
    let exporter = NCExportManager()

    private init() {}
}
