import Foundation
import UIKit

enum KeyboardSuggestionEngine {
    @MainActor private static let checker = UITextChecker()

    static func currentWord(in context: String) -> String? {
        guard let last = context.last, isWordCharacter(last) else { return nil }
        let reversedWord = context.reversed().prefix(while: isWordCharacter)
        let word = String(reversedWord.reversed())
        return word.isEmpty ? nil : word
    }

    static func replacementEdits(suggestion: String, context: String) -> [KeyboardEdit] {
        guard let word = currentWord(in: context) else {
            return [.insert(suggestion + " ")]
        }

        return Array(repeating: .deleteBackward, count: word.count)
            + [.insert(suggestion + " ")]
    }

    @MainActor
    static func suggestions(for context: String, language: String = "en_US") -> [String] {
        guard let word = currentWord(in: context), word.count >= 2 else { return [] }
        let range = NSRange(location: 0, length: (word as NSString).length)
        let misspelled = checker.rangeOfMisspelledWord(
            in: word,
            range: range,
            startingAt: 0,
            wrap: false,
            language: language
        )
        let candidates: [String]

        if misspelled.location != NSNotFound {
            candidates = checker.guesses(
                forWordRange: range,
                in: word,
                language: language
            ) ?? []
        } else {
            candidates = checker.completions(
                forPartialWordRange: range,
                in: word,
                language: language
            ) ?? []
        }

        var seen = Set<String>()
        return candidates.compactMap { candidate in
            let value = matchingCapitalization(of: word, suggestion: candidate)
            let key = value.lowercased()
            guard key != word.lowercased(), seen.insert(key).inserted else { return nil }
            return value
        }
        .prefix(3)
        .map(\.self)
    }

    @MainActor
    static func correction(for context: String, language: String = "en_US") -> String? {
        guard let word = currentWord(in: context), word.count >= 2 else { return nil }
        let range = NSRange(location: 0, length: (word as NSString).length)
        let misspelled = checker.rangeOfMisspelledWord(
            in: word,
            range: range,
            startingAt: 0,
            wrap: false,
            language: language
        )
        guard misspelled.location != NSNotFound,
              let candidate = checker.guesses(
                forWordRange: range,
                in: word,
                language: language
              )?.first else {
            return nil
        }
        return matchingCapitalization(of: word, suggestion: candidate)
    }

    private static func isWordCharacter(_ character: Character) -> Bool {
        character.isLetter || character.isNumber || character == "'" || character == "’"
    }

    private static func matchingCapitalization(of word: String, suggestion: String) -> String {
        guard word.first?.isUppercase == true, let first = suggestion.first else {
            return suggestion
        }
        return first.uppercased() + String(suggestion.dropFirst())
    }
}

extension Notification.Name {
    static let tiloqKeyboardContextDidChange = Notification.Name(
        "com.tiloq.keyboard.context-did-change"
    )
}
