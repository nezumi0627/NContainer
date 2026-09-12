import Foundation

final class NCBootManager {
    private(set) var isReady = false

    func start() {
        guard !isReady else { return }
        isReady = true
    }
}
