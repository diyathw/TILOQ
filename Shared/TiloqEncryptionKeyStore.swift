import Foundation

enum TiloqEncryptionKeyStore {
    static func load(
        from defaults: UserDefaults = TiloqSettings.sharedDefaults
    ) -> String? {
        defaults.synchronize()
        let value = defaults.string(forKey: TiloqSettings.encryptionKeyTextKey)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return value?.isEmpty == false ? value : nil
    }

    static func save(
        _ keyText: String,
        in defaults: UserDefaults = TiloqSettings.sharedDefaults
    ) throws {
        _ = try TiloqTextEncryption.keyData(from: keyText)
        let normalized = keyText.trimmingCharacters(in: .whitespacesAndNewlines)
        defaults.set(normalized, forKey: TiloqSettings.encryptionKeyTextKey)
    }
}
