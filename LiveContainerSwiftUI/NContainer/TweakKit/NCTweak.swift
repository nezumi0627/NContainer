import Foundation

struct NCTweak: Identifiable, Codable, Hashable {
    let id: String
    let displayName: String
    let fileName: String
    var isEnabled: Bool
}

final class NCTweakManager {
    func discover(in directory: URL) -> [NCTweak] {
        let fileManager = FileManager.default
        guard let names = try? fileManager.contentsOfDirectory(atPath: directory.path) else { return [] }
        return names
            .filter { $0.hasSuffix(".dylib") }
            .sorted()
            .map { NCTweak(id: $0, displayName: URL(fileURLWithPath: $0).deletingPathExtension().lastPathComponent, fileName: $0, isEnabled: true) }
    }
}
