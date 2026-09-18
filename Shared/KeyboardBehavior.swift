import Foundation

enum KeyboardLayer: String, CaseIterable, Sendable {
    case letters
    case numbers
    case symbols

    static let numberShortcutRow = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]

    var rows: [[String]] {
        switch self {
        case .letters:
            [
                ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
                ["A", "S", "D", "F", "G", "H", "J", "K", "L"],
                ["Z", "X", "C", "V", "B", "N", "M"]
            ]
        case .numbers:
            [
                ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
                ["-", "/", ":", ";", "(", ")", "$", "&", "@", "\""],
                [".", ",", "?", "!", "'"]
            ]
        case .symbols:
            [
                ["[", "]", "{", "}", "#", "%", "^", "*", "+", "="],
                ["_", "\\", "|", "~", "<", ">", "€", "£", "¥", "•"],
                [".", ",", "?", "!", "'"]
            ]
        }
    }
}

enum ShiftState: Sendable {
    case off
    case on
    case locked

    var isUppercase: Bool { self != .off }
}

enum KeyboardEdit: Equatable, Sendable {
    case insert(String)
    case deleteBackward
    case moveCursor(Int)
    case replaceBeforeCursor(original: String, replacement: String)
}

enum KeyboardBehavior {
    enum ToolbarAction: Hashable {
        case ai(AIAction)
        case encrypt
        case decrypt
    }

    static func toolbarActions(
        rewriteEnabled: Bool = true,
        grammarEnabled: Bool = true,
        improveEnabled: Bool = true,
        encryptionEnabled: Bool
    ) -> [ToolbarAction] {
        var actions: [ToolbarAction] = []
        if rewriteEnabled { actions.append(.ai(.rewrite)) }
        if grammarEnabled { actions.append(.ai(.grammar)) }
        if improveEnabled { actions.append(.ai(.improve)) }
        if encryptionEnabled {
            actions.append(.encrypt)
            actions.append(.decrypt)
        }
        return actions
    }

    static func encryptionSource(selectedText: String?) -> String? {
        guard let selectedText, selectedText.isEmpty == false else { return nil }
        return selectedText
    }

    /// A custom keyboard extension without Full Access cannot read the
    /// system pasteboard, so decryption reads from the host app's text
    /// field instead (the same document-proxy mechanism `encryptionSource`
    /// uses): the current selection if there is one, otherwise whatever
    /// text is already in the field.
    static func decryptionSource(selectedText: String?, sourceText: String) -> String? {
        if let selectedText, selectedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
            return selectedText
        }
        let trimmedSource = sourceText.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedSource.isEmpty ? nil : sourceText
    }

    /// The keyboard height in points.
    ///
    /// The AI result panel replaces the key rows instead of stacking on top of
    /// them, so a visible result no longer changes the height. Pass
    /// `availableScreenHeight` (for example in landscape, where the screen is
    /// short) to keep the keyboard from covering the host text field: the
    /// height is then capped at half of the available height.
    static func preferredHeight(
        includesNumberRow: Bool = true,
        availableScreenHeight: CGFloat? = nil
    ) -> CGFloat {
        let baseHeight: CGFloat = 262
        let uncapped = baseHeight + (includesNumberRow ? 52 : 0)
        guard let availableScreenHeight, availableScreenHeight > 0 else { return uncapped }
        return min(uncapped, availableScreenHeight * 0.5)
    }

    static func shouldCapitalize(after context: String?) -> Bool {
        guard let context, context.isEmpty == false else { return true }
        guard let lastMeaningful = context.reversed().first(where: { $0.isWhitespace == false }) else { return true }
        return ".!?\n".contains(lastMeaningful)
    }

    static func spaceEdits(
        after context: String?,
        doubleSpacePeriodEnabled: Bool = true
    ) -> [KeyboardEdit] {
        guard doubleSpacePeriodEnabled else { return [.insert(" ")] }
        guard let context, context.hasSuffix(" ") else {
            return [.insert(" ")]
        }

        let beforeSpace = context.dropLast().last
        guard let beforeSpace,
              beforeSpace.isWhitespace == false,
              ".,!?;:".contains(beforeSpace) == false else {
            return [.insert(" ")]
        }

        return [.deleteBackward, .insert(". ")]
    }

    static func shouldInsertSpace(afterCursorDrag didMoveCursor: Bool) -> Bool {
        didMoveCursor == false
    }

    static func characterKeysEnabled(isCursorModeActive: Bool) -> Bool {
        isCursorModeActive == false
    }

    static func applying(_ edit: KeyboardEdit, to text: inout String) {
        switch edit {
        case .insert(let value):
            text.append(value)
        case .deleteBackward:
            if text.isEmpty == false { text.removeLast() }
        case .moveCursor:
            break
        case .replaceBeforeCursor(let original, let replacement):
            guard text.hasSuffix(original) else { return }
            text.removeLast(original.count)
            text.append(replacement)
        }
    }
}
