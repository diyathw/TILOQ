import Foundation

enum KeyboardBackdropStyle: String, CaseIterable, Identifiable, Sendable {
    case none = "None"
    case carbon = "Carbon"
    case aurora = "Aurora"
    case midnight = "Midnight"
    case custom = "Custom Photo"

    var id: String { rawValue }
}
