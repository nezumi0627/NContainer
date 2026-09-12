import Foundation

struct NCPluginManifest: Codable, Hashable {
    let identifier: String
    let name: String
    let version: String
    let apiVersion: Int
    let entryPoint: String?

    static let currentAPIVersion = 1
}

enum NCPluginError: LocalizedError {
    case invalidManifest
    case unsupportedAPIVersion(Int)

    var errorDescription: String? {
        switch self {
        case .invalidManifest: "プラグインの manifest.json が不正です。"
        case .unsupportedAPIVersion(let version): "未対応のプラグイン API バージョンです: \(version)"
        }
    }
}
