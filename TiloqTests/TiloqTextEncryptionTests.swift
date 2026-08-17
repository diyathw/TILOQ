import Foundation
import Testing
@testable import Tiloq

struct TiloqTextEncryptionTests {
    @Test("Generated keys use the portable 256-bit key format")
    func generatedKeyFormat() throws {
        let keyText = TiloqTextEncryption.generateKeyText()
        let keyData = try TiloqTextEncryption.keyData(from: keyText)

        #expect(keyText.hasPrefix("TILOQKEY1."))
        #expect(keyData.count == 32)
    }

    @Test("Unicode text survives an encryption round trip")
    func roundTrip() throws {
        let keyText = TiloqTextEncryption.generateKeyText()
        let plaintext = "Meet me tomorrow at 8 🔐"

        let encrypted = try TiloqTextEncryption.encrypt(plaintext, keyText: keyText)
        let decrypted = try TiloqTextEncryption.decrypt(encrypted, keyText: keyText)

        #expect(encrypted.hasPrefix("TILOQ1."))
        #expect(encrypted.contains(plaintext) == false)
        #expect(decrypted == plaintext)
    }

    @Test("A user-defined text key encrypts and decrypts locally")
    func customTextKeyRoundTrip() throws {
        let keyText = "my own private project phrase"
        let encrypted = try TiloqTextEncryption.encrypt(
            "Selected text",
            keyText: keyText
        )

        #expect(
            try TiloqTextEncryption.decrypt(encrypted, keyText: keyText)
                == "Selected text"
        )
        #expect(try TiloqTextEncryption.keyData(from: keyText).count == 32)
    }

    @Test("A user-defined key is stored in shared app preferences")
    func customTextKeyStorage() throws {
        let suiteName = "TiloqEncryptionKeyStoreTests-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        try TiloqEncryptionKeyStore.save("  my own key text  ", in: defaults)

        let keyboardDefaults = try #require(UserDefaults(suiteName: suiteName))
        #expect(
            TiloqEncryptionKeyStore.load(from: keyboardDefaults)
                == "my own key text"
        )
    }

    @Test("A different key cannot decrypt a message")
    func wrongKeyFails() throws {
        let encrypted = try TiloqTextEncryption.encrypt(
            "Private message",
            keyText: TiloqTextEncryption.generateKeyText()
        )
        let wrongKey = TiloqTextEncryption.generateKeyText()

        #expect(throws: TiloqEncryptionError.authenticationFailed) {
            try TiloqTextEncryption.decrypt(encrypted, keyText: wrongKey)
        }
    }

    @Test("Modified ciphertext fails authentication")
    func tamperingFails() throws {
        let keyText = TiloqTextEncryption.generateKeyText()
        let encrypted = try TiloqTextEncryption.encrypt("Do not modify", keyText: keyText)
        let index = encrypted.index(
            encrypted.startIndex,
            offsetBy: TiloqTextEncryption.messagePrefix.count + 5
        )
        var tampered = encrypted
        tampered.replaceSubrange(index ... index, with: encrypted[index] == "A" ? "B" : "A")

        #expect(throws: TiloqEncryptionError.authenticationFailed) {
            try TiloqTextEncryption.decrypt(tampered, keyText: keyText)
        }
    }

    @Test("Invalid keys and messages are rejected")
    func invalidFormatsFail() {
        #expect(throws: TiloqEncryptionError.invalidKey) {
            try TiloqTextEncryption.encrypt("Hello", keyText: "   ")
        }
        #expect(throws: TiloqEncryptionError.invalidKey) {
            try TiloqTextEncryption.encrypt("Hello", keyText: "TILOQKEY1.not-valid")
        }
        #expect(throws: TiloqEncryptionError.invalidMessage) {
            try TiloqTextEncryption.decrypt(
                "not-a-message",
                keyText: TiloqTextEncryption.generateKeyText()
            )
        }
        #expect(throws: TiloqEncryptionError.emptyPlaintext) {
            try TiloqTextEncryption.encrypt(
                "   ",
                keyText: TiloqTextEncryption.generateKeyText()
            )
        }
    }
}
