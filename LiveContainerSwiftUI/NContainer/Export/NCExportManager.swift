import Foundation

final class NCExportManager {
    /// Keeps export policy in the NContainer layer while reusing LiveContainer's signer/archiver.
    func exportIPA(bundleName: String, extraInfo: [String: Any] = [:]) throws -> URL {
        var error: NSError?
        guard let url = LCUtils.archiveIPA(withBundleName: bundleName, includingExtraInfoDict: extraInfo, error: &error) else {
            throw error ?? NSError(domain: "NContainer.Export", code: 1, userInfo: [NSLocalizedDescriptionKey: "IPA の作成に失敗しました。"])
        }
        return url
    }
}
