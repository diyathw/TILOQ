import Foundation

enum KeyboardRGBAnimation {
    static let duration = 4.8

    static func phaseOffset(for identifier: String) -> Double {
        let hash = identifier.unicodeScalars.reduce(UInt64(17)) { partial, scalar in
            partial &* 31 &+ UInt64(scalar.value)
        }
        return Double(hash % 360)
    }
}
