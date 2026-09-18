import Foundation
import Testing
@testable import Tiloq

struct KeyboardBehaviorTests {
    @Test(
        "Encryption is added to the writing toolbar",
        arguments: [
            (enabled: false, expected: [
                KeyboardBehavior.ToolbarAction.ai(.rewrite),
                .ai(.grammar),
                .ai(.improve)
            ]),
            (enabled: true, expected: [
                KeyboardBehavior.ToolbarAction.ai(.rewrite),
                .ai(.grammar),
                .ai(.improve),
                .encrypt,
                .decrypt
            ])
        ]
    )
    func encryptionToolbarAction(
        enabled: Bool,
        expected: [KeyboardBehavior.ToolbarAction]
    ) {
        #expect(
            KeyboardBehavior.toolbarActions(encryptionEnabled: enabled) == expected
        )
    }

    @Test("Disabled AI tools are removed from the keyboard toolbar")
    func disabledAIToolsAreHidden() {
        #expect(
            KeyboardBehavior.toolbarActions(
                rewriteEnabled: false,
                grammarEnabled: true,
                improveEnabled: false,
                encryptionEnabled: true
            ) == [.ai(.grammar), .encrypt, .decrypt]
        )
    }

    @Test(
        "Encryption requires selected text",
        arguments: [
            (selection: nil, expected: nil),
            (selection: "", expected: nil),
            (selection: "private words", expected: "private words")
        ] as [(selection: String?, expected: String?)]
    )
    func encryptionSelection(selection: String?, expected: String?) {
        #expect(
            KeyboardBehavior.encryptionSource(selectedText: selection) == expected
        )
    }

    @Test("Keyboard glass roles keep consistent surface metrics")
    func keyboardGlassMetrics() {
        #expect(KeyboardGlassRole.key.cornerRadius == 7)
        #expect(KeyboardGlassRole.modifier.cornerRadius == 7)
        #expect(KeyboardGlassRole.toolbar.cornerRadius == 10)
        #expect(KeyboardGlassRole.suggestion.cornerRadius == 8)
        #expect(KeyboardGlassRole.result.cornerRadius == 10)
        #expect(KeyboardGlassRole.allCases.allSatisfy { role in
            role.tintOpacity > 0 && role.tintOpacity <= 1
        })
        #expect(KeyboardGlassRole.result.isInteractive == false)
    }

    @Test("RGB wave phase offsets are stable and distributed")
    func rgbWavePhaseOffsets() {
        let firstQ = KeyboardRGBAnimation.phaseOffset(for: "Q")
        let secondQ = KeyboardRGBAnimation.phaseOffset(for: "Q")
        let w = KeyboardRGBAnimation.phaseOffset(for: "W")

        #expect(firstQ == secondQ)
        #expect(firstQ != w)
        #expect(firstQ >= 0 && firstQ < 360)
        #expect(w >= 0 && w < 360)
        #expect(KeyboardRGBAnimation.duration > 0)
    }

    @Test(
        "Auto-capitalization follows sentence boundaries",
        arguments: [
            (context: nil, expected: true),
            (context: "", expected: true),
            (context: "Hello. ", expected: true),
            (context: "Really? ", expected: true),
            (context: "Great!\n", expected: true),
            (context: "hello ", expected: false)
        ]
    )
    func capitalization(context: String?, expected: Bool) {
        #expect(KeyboardBehavior.shouldCapitalize(after: context) == expected)
    }

    @Test("Double-space inserts a period")
    func doubleSpaceShortcut() {
        let edits = KeyboardBehavior.spaceEdits(after: "See you tomorrow ")

        #expect(edits == [.deleteBackward, .insert(". ")])
    }

    @Test("Double-space does not follow punctuation")
    func punctuationDoesNotReceiveAnotherPeriod() {
        let edits = KeyboardBehavior.spaceEdits(after: "Done. ")

        #expect(edits == [.insert(" ")])
    }

    @Test("Normal space remains a normal insertion")
    func normalSpace() {
        #expect(KeyboardBehavior.spaceEdits(after: "Hello") == [.insert(" ")])
    }

    @Test("The period shortcut can be disabled")
    func disabledDoubleSpaceShortcut() {
        #expect(
            KeyboardBehavior.spaceEdits(
                after: "See you tomorrow ",
                doubleSpacePeriodEnabled: false
            ) == [.insert(" ")]
        )
    }

    @Test("Long-press keys provide native-style alternates", arguments: [
        (key: "e", expected: ["é", "è", "ê", "ë", "ē", "ė", "ę"]),
        (key: "N", expected: ["Ñ", "Ń"]),
        (key: ".", expected: ["…"]),
        (key: "-", expected: ["–", "—", "•"]),
        (key: "q", expected: [])
    ])
    func alternateCharacters(key: String, expected: [String]) {
        #expect(KeyboardAlternates.characters(for: key) == expected)
    }

    @Test("Every keyboard layer provides visible keys", arguments: KeyboardLayer.allCases)
    func keyboardLayersContainKeys(_ layer: KeyboardLayer) {
        #expect(layer.rows.isEmpty == false)
        #expect(layer.rows.allSatisfy { $0.isEmpty == false })
    }

    @Test("The letter keyboard has a complete number shortcut row")
    func numberShortcutRow() {
        #expect(KeyboardLayer.numberShortcutRow == [
            "1", "2", "3", "4", "5", "6", "7", "8", "9", "0"
        ])
    }

    @Test(
        "Every character key is present on its layer",
        arguments: [
            (layer: KeyboardLayer.letters, expected: Array("QWERTYUIOPASDFGHJKLZXCVBNM").map(String.init)),
            (layer: KeyboardLayer.numbers, expected: [
                "1", "2", "3", "4", "5", "6", "7", "8", "9", "0",
                "-", "/", ":", ";", "(", ")", "$", "&", "@", "\"",
                ".", ",", "?", "!", "'"
            ]),
            (layer: KeyboardLayer.symbols, expected: [
                "[", "]", "{", "}", "#", "%", "^", "*", "+", "=",
                "_", "\\", "|", "~", "<", ">", "€", "£", "¥", "•",
                ".", ",", "?", "!", "'"
            ])
        ]
    )
    func characterKeyInventory(layer: KeyboardLayer, expected: [String]) {
        #expect(layer.rows.flatMap(\.self) == expected)
    }

    @Test("Letter keys respect all Shift states", arguments: [
        (state: ShiftState.off, expected: false),
        (state: ShiftState.on, expected: true),
        (state: ShiftState.locked, expected: true)
    ])
    func shiftStateCapitalization(state: ShiftState, expected: Bool) {
        #expect(state.isUppercase == expected)
    }

    @Test("Every character key can be inserted", arguments: KeyboardLayer.allCases)
    func everyCharacterKeyCanInsert(_ layer: KeyboardLayer) {
        var text = ""
        let keys = layer.rows.flatMap(\.self)

        keys.forEach { KeyboardBehavior.applying(.insert($0), to: &text) }

        #expect(text == keys.joined())
    }

    @Test("Space and Return insert their expected characters", arguments: [" ", "\n"])
    func controlCharacterInsertion(_ character: String) {
        var text = "TILOQ"

        KeyboardBehavior.applying(.insert(character), to: &text)

        #expect(text == "TILOQ" + character)
    }

    @Test("A Space key tap inserts space, while a cursor drag does not", arguments: [
        (didMoveCursor: false, expected: true),
        (didMoveCursor: true, expected: false)
    ])
    func spaceGestureRelease(didMoveCursor: Bool, expected: Bool) {
        #expect(KeyboardBehavior.shouldInsertSpace(afterCursorDrag: didMoveCursor) == expected)
    }

    @Test("Cursor mode disables character keys", arguments: [
        (isCursorModeActive: false, expected: true),
        (isCursorModeActive: true, expected: false)
    ])
    func cursorModeCharacterKeys(isCursorModeActive: Bool, expected: Bool) {
        #expect(
            KeyboardBehavior.characterKeysEnabled(
                isCursorModeActive: isCursorModeActive
            ) == expected
        )
    }

    @Test("Delete removes one complete character, including Unicode")
    func deleteBackward() {
        var text = "TILOQ👍🏽"

        KeyboardBehavior.applying(.deleteBackward, to: &text)

        #expect(text == "TILOQ")
    }

    @Test("Delete is safe when the document is empty")
    func deleteBackwardFromEmptyDocument() {
        var text = ""

        KeyboardBehavior.applying(.deleteBackward, to: &text)

        #expect(text.isEmpty)
    }

    @Test("Cursor movement does not insert or delete text", arguments: [-3, -1, 1, 4])
    func cursorMovementPreservesText(_ offset: Int) {
        var text = "TILOQ"

        KeyboardBehavior.applying(.moveCursor(offset), to: &text)

        #expect(text == "TILOQ")
    }

    @Test("Encryption replaces only the matching draft before the cursor")
    func encryptedDraftReplacement() {
        var text = "Earlier text\nsecret draft"

        KeyboardBehavior.applying(
            .replaceBeforeCursor(
                original: "secret draft",
                replacement: "TILOQ1.encrypted"
            ),
            to: &text
        )

        #expect(text == "Earlier text\nTILOQ1.encrypted")
    }

    @Test("Encryption does not delete text when the draft changed")
    func staleEncryptedDraftDoesNotReplace() {
        var text = "new draft"

        KeyboardBehavior.applying(
            .replaceBeforeCursor(
                original: "old draft",
                replacement: "TILOQ1.encrypted"
            ),
            to: &text
        )

        #expect(text == "new draft")
    }

    @Test(
        "Keyboard height depends only on the number row, never on the result panel",
        arguments: [
            (includesNumberRow: true, expected: CGFloat(314)),
            (includesNumberRow: false, expected: CGFloat(262))
        ]
    )
    func preferredHeight(includesNumberRow: Bool, expected: CGFloat) {
        #expect(
            KeyboardBehavior.preferredHeight(includesNumberRow: includesNumberRow) == expected
        )
        #expect(
            KeyboardBehavior.preferredHeight(
                includesNumberRow: includesNumberRow,
                availableScreenHeight: nil
            ) == expected
        )
    }

    @Test("The keyboard height defaults to including the number row")
    func preferredHeightDefaults() {
        #expect(KeyboardBehavior.preferredHeight() == 314)
    }

    @Test(
        "The keyboard never takes more than half of a short (landscape) screen",
        arguments: [
            (availableScreenHeight: CGFloat(400), includesNumberRow: true, expected: CGFloat(200)),
            (availableScreenHeight: CGFloat(500), includesNumberRow: true, expected: CGFloat(250)),
            (availableScreenHeight: CGFloat(390), includesNumberRow: false, expected: CGFloat(195))
        ]
    )
    func preferredHeightIsCappedOnShortScreens(
        availableScreenHeight: CGFloat,
        includesNumberRow: Bool,
        expected: CGFloat
    ) {
        #expect(
            KeyboardBehavior.preferredHeight(
                includesNumberRow: includesNumberRow,
                availableScreenHeight: availableScreenHeight
            ) == expected
        )
    }

    @Test(
        "A generous screen height leaves the measured keyboard height untouched",
        arguments: [
            (availableScreenHeight: CGFloat(1000), includesNumberRow: false, expected: CGFloat(262)),
            (availableScreenHeight: CGFloat(852), includesNumberRow: true, expected: CGFloat(314)),
            (availableScreenHeight: CGFloat(0), includesNumberRow: true, expected: CGFloat(314))
        ]
    )
    func preferredHeightIsNotCappedOnTallScreens(
        availableScreenHeight: CGFloat,
        includesNumberRow: Bool,
        expected: CGFloat
    ) {
        #expect(
            KeyboardBehavior.preferredHeight(
                includesNumberRow: includesNumberRow,
                availableScreenHeight: availableScreenHeight
            ) == expected
        )
    }

    @Test("Suggestion engine finds only the word immediately before the cursor", arguments: [
        (context: "hello wor", expected: "wor"),
        (context: "defenetely", expected: "defenetely"),
        (context: "we can't", expected: "can't"),
        (context: "finished ", expected: nil),
        (context: "", expected: nil)
    ])
    func currentSuggestionWord(context: String, expected: String?) {
        #expect(KeyboardSuggestionEngine.currentWord(in: context) == expected)
    }

    @Test("Tapping a suggestion replaces the current word and adds a space")
    func suggestionReplacementEdits() {
        let edits = KeyboardSuggestionEngine.replacementEdits(
            suggestion: "definitely",
            context: "I am defenetely"
        )
        let expected: [KeyboardEdit] = Array(repeating: .deleteBackward, count: 10)
            + [.insert("definitely ")]

        #expect(edits == expected)
    }

    @Test("RGB lighting is off by default and persists when enabled")
    func rgbLightingPreference() throws {
        let suiteName = "TiloqSettingsTests-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        #expect(TiloqSettings.rgbLightingEnabled(in: defaults) == false)

        defaults.set(true, forKey: TiloqSettings.rgbLightingKey)

        #expect(TiloqSettings.rgbLightingEnabled(in: defaults))
    }

    @Test("Keyboard background choices remain stable")
    func keyboardBackdropChoices() {
        #expect(KeyboardBackdropStyle.allCases.map(\.rawValue) == [
            "None", "Carbon", "Aurora", "Midnight", "Custom Photo"
        ])
    }

    @Test("A selected keyboard image is saved in the shared container")
    func customKeyboardImageStorage() throws {
        let container = FileManager.default.temporaryDirectory
            .appending(path: "TiloqBackdropTests-\(UUID().uuidString)", directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: container, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: container) }
        let imageData = Data([0x54, 0x49, 0x4C, 0x4F, 0x51])

        let savedURL = try TiloqSettings.saveCustomBackdrop(imageData, in: container)

        #expect(savedURL.lastPathComponent == TiloqSettings.customBackdropFilename)
        #expect(try Data(contentsOf: savedURL) == imageData)
    }
}
