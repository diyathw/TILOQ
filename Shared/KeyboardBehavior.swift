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
        }
        return actions
    }

    static func encryptionSource(selectedText: String?) -> String? {
        guard let selectedText, selectedText.isEmpty == false else { return nil }
        return selectedText
    }

    static func preferredHeight(
        isResultVisible: Bool,
        includesNumberRow: Bool = true
    ) -> CGFloat {
        let baseHeight: CGFloat = isResultVisible ? 520 : 348
        return baseHeight + (includesNumberRow ? 52 : 0)
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
