import SwiftUI

enum KeyboardGlassRole: CaseIterable, Sendable {
    case key
    case modifier
    case toolbar
    case suggestion
    case result

    var cornerRadius: CGFloat {
        switch self {
        case .key, .modifier: 7
        case .suggestion: 8
        case .toolbar, .result: 10
        }
    }

    var tintOpacity: Double {
        switch self {
        case .key: 0.20
        case .modifier: 0.30
        case .toolbar: 0.20
        case .suggestion: 0.18
        case .result: 0.24
        }
    }

    var isInteractive: Bool { self != .result }
}

extension View {
    func keyboardGlass(_ role: KeyboardGlassRole, tint: Color) -> some View {
        glassEffect(
            .regular
                .tint(tint.opacity(role.tintOpacity))
                .interactive(role.isInteractive),
            in: .rect(cornerRadius: role.cornerRadius)
        )
    }
}
