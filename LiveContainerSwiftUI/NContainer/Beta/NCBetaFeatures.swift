import Foundation

enum NCBetaFeature: String, CaseIterable, Identifiable {
    case pluginSystem = "NCBeta.PluginSystem"
    case tweakManager = "NCBeta.TweakManager"
    case ncontainerHome = "NCBeta.NContainerHome"
    case fullscreenApps = "NCBeta.FullscreenApps"
    case nStatus = "NCBeta.NStatus"
    case ipaExport = "NCBeta.IPAExport"
    case keepOriginalIPA = "NCBeta.KeepOriginalIPA"

    static var ncontainerFeatures: [NCBetaFeature] {
        [.ncontainerHome, .nStatus, .fullscreenApps, .ipaExport, .keepOriginalIPA]
    }

    var id: String { rawValue }

    var title: String {
        switch self {
        case .pluginSystem: "Plugin System"
        case .tweakManager: "Tweak Manager"
        case .ncontainerHome: "NContainer Home"
        case .fullscreenApps: "Fullscreen Apps"
        case .nStatus: "NStatus"
        case .ipaExport: "IPA Export"
        case .keepOriginalIPA: "Keep Original IPA"
        }
    }

    var description: String {
        switch self {
        case .pluginSystem: "NContainer プラグイン基盤を有効にします。"
        case .tweakManager: "Tweak 管理 UI を有効にします。"
        case .ncontainerHome: "アプリを Home 風のグリッドで表示します。"
        case .fullscreenApps: "フルスクリーン関連の Beta 機能を有効にします。"
        case .nStatus: "カスタム NStatus オーバーレイを有効にします。"
        case .ipaExport: "アプリの IPA エクスポート導線を有効にします。"
        case .keepOriginalIPA: "インストール元 IPA の保持を有効にします。"
        }
    }

    var defaultValue: Bool { self == .ncontainerHome }
}

enum NCBetaFeatures {
    static let disableLiquidGlassKey = "NCBeta.DisableLiquidGlass"

    static var isLiquidGlassDisabled: Bool {
        UserDefaults.standard.bool(forKey: disableLiquidGlassKey)
    }

    static func isEnabled(_ feature: NCBetaFeature) -> Bool {
        let defaults = UserDefaults.standard
        guard defaults.object(forKey: feature.rawValue) != nil else {
            return feature.defaultValue
        }
        return defaults.bool(forKey: feature.rawValue)
    }

    static func setEnabled(_ enabled: Bool, for feature: NCBetaFeature) {
        UserDefaults.standard.set(enabled, forKey: feature.rawValue)
    }

    static func disableAll() {
        NCBetaFeature.allCases.forEach { setEnabled(false, for: $0) }
    }
}
