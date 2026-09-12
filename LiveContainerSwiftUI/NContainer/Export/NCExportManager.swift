import Foundation

final class NCExportManager {
    /// Keeps export policy in the NContainer layer while reusing LiveContainer's signer/archiver.
    func exportIPA(bundleName: String, extraInfo: [String: Any] = [:]) throws -> URL {
        try LCUtils.archiveIPA(withBundleName: bundleName, includingExtraInfoDict: extraInfo)
    }
}
