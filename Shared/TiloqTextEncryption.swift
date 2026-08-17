import CryptoKit
import Foundation

enum TiloqTextEncryption {
    static let keyPrefix = "TILOQKEY1."
    static let messagePrefix = "TILOQ1."

    static func generateKeyText() -> String {
        let key = SymmetricKey(size: .bits256)
        let data = key.withUnsafeBytes { Data($0) }
        return keyPrefix + base64URLEncoded(data)
    }

    static func keyData(from keyText: String) throws -> Data {
        let normalized = keyText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard normalized.isEmpty == false else {
            throw TiloqEncryptionError.invalidKey
        }

        if normalized.hasPrefix(keyPrefix) {
            guard let data = base64URLDecoded(
                String(normalized.dropFirst(keyPrefix.count))
            ), data.count == 32 else {
                throw TiloqEncryptionError.invalidKey
            }
            return data
        }

        return Data(SHA256.hash(data: Data(normalized.utf8)))
    }

    static func encrypt(_ plaintext: String, keyText: String) throws -> String {
        guard plaintext.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw TiloqEncryptionError.emptyPlaintext
        }

        let key = SymmetricKey(data: try keyData(from: keyText))
        let sealedBox = try AES.GCM.seal(
            Data(plaintext.utf8),
            using: key,
            authenticating: authenticatedData
        )
        guard let combined = sealedBox.combined else {
            throw TiloqEncryptionError.invalidMessage
        }
        return messagePrefix + base64URLEncoded(combined)
    }

    static func decrypt(_ encryptedText: String, keyText: String) throws -> String {
        let normalized = encryptedText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard normalized.hasPrefix(messagePrefix),
              let combined = base64URLDecoded(
                String(normalized.dropFirst(messagePrefix.count))
              ),
              combined.count >= 28 else {
            throw TiloqEncryptionError.invalidMessage
        }

        let key = SymmetricKey(data: try keyData(from: keyText))
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: combined)
            let plaintext = try AES.GCM.open(
                sealedBox,
                using: key,
                authenticating: authenticatedData
            )
            guard let result = String(data: plaintext, encoding: .utf8) else {
                throw TiloqEncryptionError.invalidMessage
            }
            return result
        } catch let error as TiloqEncryptionError {
            throw error
        } catch {
            throw TiloqEncryptionError.authenticationFailed
        }
    }

    private static var authenticatedData: Data {
        Data(messagePrefix.utf8)
    }

    private static func base64URLEncoded(_ data: Data) -> String {
        data.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    private static func base64URLDecoded(_ text: String) -> Data? {
        var base64 = text
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let padding = (4 - base64.count % 4) % 4
        base64.append(String(repeating: "=", count: padding))
        guard let decoded = Data(base64Encoded: base64),
              base64URLEncoded(decoded) == text else {
            return nil
        }
        return decoded
    }
}
