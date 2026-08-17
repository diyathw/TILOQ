enum SetupGuideContent {
    struct Step: Identifiable, Equatable, Sendable {
        let id: Int
        let symbol: String
        let title: String
        let detail: String
    }

    static let settingsPath = "General → Keyboard → Keyboards → Add New Keyboard → TILOQ"
    static let requiresFullAccess = false

    static let steps = [
        Step(
            id: 1,
            symbol: "keyboard.badge.ellipsis",
            title: "Add TILOQ",
            detail: "In iPhone Settings, open \(settingsPath)."
        ),
        Step(
            id: 2,
            symbol: "globe",
            title: "Switch keyboards",
            detail: "In Messages, hold the globe key and choose TILOQ. iOS remembers your last keyboard."
        ),
        Step(
            id: 3,
            symbol: "selection.pin.in.out",
            title: "Select your writing",
            detail: "Select a sentence you want to rewrite, correct, or improve."
        ),
        Step(
            id: 4,
            symbol: "sparkles",
            title: "Fix it instantly",
            detail: "Tap Grammar, Rewrite, or Improve, then insert the on-device suggestion."
        )
    ]
}
