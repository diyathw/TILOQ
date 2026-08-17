import Foundation

enum TiloqEncryptionError: Error, Equatable, LocalizedError, Sendable {
    case emptyPlaintext
    case invalidKey
    case invalidMessage
    case authenticationFailed

    var errorDescription: String? {
        switch self {
        case .emptyPlaintext:
            "Enter a message before encrypting."
        case .invalidKey:
            "Enter your key text."
        case .invalidMessage:
            "Enter a valid TILOQ1 encrypted message."
        case .authenticationFailed:
            "This key cannot decrypt the message, or the message was modified."
        }
    }
}
