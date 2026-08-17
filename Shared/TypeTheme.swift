import SwiftUI
import UIKit

enum TypeTheme {
    static let background = Color(uiColor: .black)
    static let surface = Color(uiColor: UIColor(white: 0.085, alpha: 1))
    static let elevated = Color(uiColor: UIColor(white: 0.145, alpha: 1))
    static let key = Color(uiColor: UIColor(white: 0.20, alpha: 1))
    static let secondaryKey = Color(uiColor: UIColor(white: 0.14, alpha: 1))
    static let muted = Color(uiColor: UIColor(white: 0.62, alpha: 1))
    static let rewrite = Color(red: 0.72, green: 0.84, blue: 0.38)
    static let grammar = Color(red: 0.68, green: 0.57, blue: 0.96)
    static let improve = Color(red: 0.37, green: 0.67, blue: 0.96)
    static let encryption = Color(red: 0.92, green: 0.70, blue: 0.34)
}

enum AIAction: String, CaseIterable, Identifiable {
    case rewrite = "Rewrite"
    case grammar = "Grammar"
    case improve = "Improve"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .rewrite: "sparkles"
        case .grammar: "checkmark"
        case .improve: "star.fill"
        }
    }

    var tint: Color {
        switch self {
        case .rewrite: TypeTheme.rewrite
        case .grammar: TypeTheme.grammar
        case .improve: TypeTheme.improve
        }
    }
}

enum RewriteTone: String, CaseIterable, Identifiable {
    case casual = "Casual"
    case professional = "Professional"
    case friendly = "Friendly"
    case shorter = "Shorter"

    var id: String { rawValue }
}

enum TypeCopy {
    static let original = "i defenetely will be there tommorow, cant wait to see you and discuss about the project."
    static let grammar = "I will definitely be there tomorrow. I can’t wait to see you and discuss the project."
    static let rewrite = "I’ll definitely be there tomorrow! Can’t wait to see you and talk about the project."
    static let improve = "I’ll definitely be there tomorrow. I’m looking forward to meeting with you and discussing the project in more detail."

    static func rewrite(for tone: RewriteTone) -> String {
        switch tone {
        case .casual: rewrite
        case .professional: "I will be there tomorrow and look forward to discussing the project with you."
        case .friendly: "I’ll definitely be there tomorrow! I’m really looking forward to seeing you and chatting about the project."
        case .shorter: "I’ll be there tomorrow—looking forward to discussing the project."
        }
    }
}

struct TactileButtonStyle: ButtonStyle {
    let tint: Color?

    init(tint: Color? = nil) {
        self.tint = tint
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .brightness(configuration.isPressed ? -0.08 : 0)
            .offset(y: configuration.isPressed ? 2 : 0)
            .shadow(
                color: .black.opacity(configuration.isPressed ? 0.15 : 0.45),
                radius: configuration.isPressed ? 1 : 3,
                y: configuration.isPressed ? 1 : 3
            )
            .animation(.spring(response: 0.22, dampingFraction: 0.62), value: configuration.isPressed)
    }
}

enum Haptics {
    @MainActor
    static func tap() {
        guard isEnabled else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: 0.75)
    }

    @MainActor
    static func success() {
        guard isEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    private static var isEnabled: Bool {
        let defaults = TiloqSettings.sharedDefaults
        guard defaults.object(forKey: TiloqSettings.hapticsKey) != nil else { return true }
        return defaults.bool(forKey: TiloqSettings.hapticsKey)
    }
}
