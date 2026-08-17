import Foundation

enum TiloqSettings {
    static let appGroupIdentifier = "group.com.tiloq.app"
    static let rgbLightingKey = "rgbLightingEnabled"
    static let keyboardBackdropKey = "keyboardBackdropStyle"
    static let customBackdropFilename = "keyboard-backdrop.jpg"
    static let keyPreviewKey = "keyPreviewEnabled"
    static let autoCapitalizationKey = "autoCapitalizationEnabled"
    static let suggestionsKey = "suggestionsEnabled"
    static let autoCorrectionKey = "autoCorrectionEnabled"
    static let capsLockKey = "capsLockEnabled"
    static let periodShortcutKey = "periodShortcutEnabled"
    static let hapticsKey = "hapticsEnabled"
    static let rewriteEnabledKey = "rewriteEnabled"
    static let grammarEnabledKey = "grammarEnabled"
    static let improveEnabledKey = "improveEnabled"
    static let defaultToneKey = "defaultTone"
    static let encryptionEnabledKey = "encryptionEnabled"
    static let encryptionKeyTextKey = "encryptionKeyText"

    static var sharedDefaults: UserDefaults {
        UserDefaults(suiteName: appGroupIdentifier) ?? .standard
    }

    static func rgbLightingEnabled(in defaults: UserDefaults = sharedDefaults) -> Bool {
        defaults.bool(forKey: rgbLightingKey)
    }

    static var sharedContainerURL: URL? {
        FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupIdentifier
        )
    }

    static func customBackdropURL(in container: URL) -> URL {
        container.appending(path: customBackdropFilename, directoryHint: .notDirectory)
    }

    @discardableResult
    static func saveCustomBackdrop(_ data: Data, in container: URL) throws -> URL {
        let url = customBackdropURL(in: container)
        try data.write(to: url, options: .atomic)
        return url
    }
}
