import SwiftUI

struct TypeKeyboardView: View {
    let sourceText: () -> String
    let selectedText: () -> String?
    let typingContext: () -> String
    let onSuggestion: (String) -> Void
    let onEdit: (KeyboardEdit) -> Void
    let onNextKeyboard: (() -> Void)?
    let contextualKey: () -> String?
    let returnKeyLabel: () -> String
    let onPreferredHeightChange: (CGFloat) -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var selectedAction: AIAction?
    @State private var tone: RewriteTone = .casual
    @State private var layer = KeyboardLayer.letters
    @State private var shiftState = ShiftState.off
    @State private var lastShiftTap = Date.distantPast
    @State private var copied = false
    @State private var generatedText = ""
    @State private var encryptedText: String?
    @State private var isGenerating = false
    @State private var typingSuggestions: [String] = []
    @State private var rgbPhase = 0.0
    @State private var isCursorModeActive = false
    @State private var encryptionNotice: String?
    @AppStorage(
        TiloqSettings.rgbLightingKey,
        store: TiloqSettings.sharedDefaults
    ) private var rgbLightingEnabled = false
    @AppStorage(
        TiloqSettings.keyboardBackdropKey,
        store: TiloqSettings.sharedDefaults
    ) private var backdropValue = KeyboardBackdropStyle.none.rawValue
    @AppStorage(TiloqSettings.keyPreviewKey, store: TiloqSettings.sharedDefaults)
    private var keyPreviewEnabled = true
    @AppStorage(TiloqSettings.autoCapitalizationKey, store: TiloqSettings.sharedDefaults)
    private var autoCapitalizationEnabled = true
    @AppStorage(TiloqSettings.suggestionsKey, store: TiloqSettings.sharedDefaults)
    private var suggestionsEnabled = true
    @AppStorage(TiloqSettings.autoCorrectionKey, store: TiloqSettings.sharedDefaults)
    private var autoCorrectionEnabled = true
    @AppStorage(TiloqSettings.capsLockKey, store: TiloqSettings.sharedDefaults)
    private var capsLockEnabled = true
    @AppStorage(TiloqSettings.periodShortcutKey, store: TiloqSettings.sharedDefaults)
    private var periodShortcutEnabled = true
    @AppStorage(TiloqSettings.encryptionEnabledKey, store: TiloqSettings.sharedDefaults)
    private var encryptionEnabled = false
    @AppStorage(TiloqSettings.rewriteEnabledKey, store: TiloqSettings.sharedDefaults)
    private var rewriteEnabled = true
    @AppStorage(TiloqSettings.grammarEnabledKey, store: TiloqSettings.sharedDefaults)
    private var grammarEnabled = true
    @AppStorage(TiloqSettings.improveEnabledKey, store: TiloqSettings.sharedDefaults)
    private var improveEnabled = true
    @AppStorage(TiloqSettings.defaultToneKey, store: TiloqSettings.sharedDefaults)
    private var defaultToneValue = RewriteTone.casual.rawValue

    var body: some View {
        VStack(spacing: 8) {
            toolBar

            if let action = selectedAction {
                ResultPanel(
                    action: action,
                    original: sourceText(),
                    result: generatedText,
                    isGenerating: isGenerating,
                    tone: $tone,
                    copied: $copied,
                    onInsert: {
                        onSuggestion(generatedText)
                        Haptics.success()
                        selectedAction = nil
                        refreshSuggestionsSoon()
                    }
                )
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .bottom)),
                    removal: .opacity
                ))
            } else if let encryptedText {
                ResultPanel(
                    action: nil,
                    original: selectedText() ?? "",
                    result: encryptedText,
                    isGenerating: false,
                    tone: $tone,
                    copied: $copied,
                    onInsert: {
                        onSuggestion(encryptedText)
                        Haptics.success()
                        self.encryptedText = nil
                        refreshSuggestionsSoon()
                    }
                )
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .bottom)),
                    removal: .opacity
                ))
            }

            KeyboardSuggestionBar(
                suggestions: layer == .letters ? typingSuggestions : [],
                isEnabled: suggestionsEnabled,
                rgbLightingEnabled: rgbLightingEnabled,
                rgbPhase: rgbPhase,
                statusMessage: encryptionNotice,
                onSelect: selectSuggestion
            )

            keyRows
        }
        .padding(.horizontal, 8)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background {
            KeyboardBackdropView(
                style: KeyboardBackdropStyle(rawValue: backdropValue) ?? .none
            )
        }
        .animation(.spring(response: 0.34, dampingFraction: 0.82), value: selectedAction)
        .animation(.spring(response: 0.34, dampingFraction: 0.82), value: encryptedText != nil)
        .task {
            tone = RewriteTone(rawValue: defaultToneValue) ?? .casual
            updateAutomaticShift()
            refreshSuggestions()
            updatePreferredHeight()
            updateRGBAnimation()
        }
        .onReceive(NotificationCenter.default.publisher(for: .tiloqKeyboardContextDidChange)) { _ in
            refreshSuggestions()
        }
        .onChange(of: selectedAction) { _, action in
            updatePreferredHeight()
        }
        .onChange(of: encryptedText) { _, _ in
            updatePreferredHeight()
        }
        .onChange(of: layer) { _, _ in
            updatePreferredHeight()
        }
        .onChange(of: autoCapitalizationEnabled) { _, _ in
            updateAutomaticShift()
        }
        .onChange(of: suggestionsEnabled) { _, _ in
            refreshSuggestions()
        }
        .onChange(of: rgbLightingEnabled) { _, _ in
            updateRGBAnimation()
        }
        .onChange(of: reduceMotion) { _, _ in
            updateRGBAnimation()
        }
        .onChange(of: encryptionEnabled) { _, _ in
            encryptionNotice = nil
            encryptedText = nil
        }
    }

    private var toolBar: some View {
        HStack(spacing: 8) {
            ForEach(
                KeyboardBehavior.toolbarActions(
                    rewriteEnabled: rewriteEnabled,
                    grammarEnabled: grammarEnabled,
                    improveEnabled: improveEnabled,
                    encryptionEnabled: encryptionEnabled
                ),
                id: \.self
            ) { toolbarAction in
                switch toolbarAction {
                case .ai(let action):
                    Button {
                        select(action)
                    } label: {
                        toolbarLabel(
                            title: action.rawValue,
                            symbol: action.symbol,
                            tint: action.tint,
                            isSelected: selectedAction == action
                        )
                    }
                    .buttonStyle(TactileButtonStyle(tint: action.tint))
                    .accessibilityHint("Shows a local AI \(action.rawValue.lowercased()) suggestion")

                case .encrypt:
                    Button {
                        Haptics.tap()
                        selectedAction = nil
                        if encryptedText == nil {
                            generateEncryptionResult()
                        } else {
                            encryptedText = nil
                        }
                    } label: {
                        toolbarLabel(
                            title: "Encrypt",
                            symbol: "lock.fill",
                            tint: TypeTheme.encryption,
                            isSelected: encryptedText != nil
                        )
                    }
                    .buttonStyle(TactileButtonStyle(tint: TypeTheme.encryption))
                    .accessibilityHint("Shows an encrypted preview of the selected text")
                }
            }
        }
        .onChange(of: tone) { _, _ in
            guard selectedAction == .rewrite else { return }
            generate(for: .rewrite)
        }
    }

    private var keyRows: some View {
        VStack(spacing: 8) {
            if layer == .letters {
                KeyboardNumberRow(
                    rgbLightingEnabled: rgbLightingEnabled,
                    rgbPhase: rgbPhase,
                    showsKeyPreview: keyPreviewEnabled,
                    isEnabled: characterKeysEnabled
                ) { number in
                    perform([.insert(number)])
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }

            ForEach(Array(layer.rows.enumerated()), id: \.offset) { index, row in
                HStack(spacing: 6) {
                    if index == 2 {
                        if layer == .letters {
                            KeyButton(
                                label: shiftState == .off ? "shift" : "shift.fill",
                                accessibilityLabel: shiftState == .locked ? "Caps Lock" : "Shift",
                                isSystemImage: true,
                                kind: .modifier,
                                isSelected: shiftState != .off,
                                rgbLightingEnabled: rgbLightingEnabled,
                                rgbPhase: rgbPhase,
                                action: handleShift
                            )
                            .frame(width: 44)
                        } else {
                            KeyButton(
                                label: layer == .numbers ? "#+=" : "123",
                                kind: .modifier,
                                rgbLightingEnabled: rgbLightingEnabled,
                                rgbPhase: rgbPhase
                            ) {
                                layer = layer == .numbers ? .symbols : .numbers
                            }
                            .frame(width: 52)
                        }
                    }

                    ForEach(row, id: \.self) { key in
                        let value = displayed(key)
                        KeyButton(
                            label: value,
                            isEnabled: characterKeysEnabled,
                            rgbLightingEnabled: rgbLightingEnabled,
                            rgbPhase: rgbPhase,
                            showsKeyPreview: keyPreviewEnabled,
                            alternateCharacters: KeyboardAlternates.characters(for: value),
                            alternateAction: insertAlternate
                        ) {
                            insert(key)
                        }
                    }

                    if index == 2 {
                        RepeatingDeleteKey(
                            rgbLightingEnabled: rgbLightingEnabled,
                            rgbPhase: rgbPhase
                        ) {
                            perform([.deleteBackward])
                        }
                            .frame(width: 44)
                    }
                }
                .padding(.horizontal, index == 1 && layer == .letters ? 16 : 0)
            }

            HStack(spacing: 6) {
                KeyButton(
                    label: layer == .letters ? "123" : "ABC",
                    kind: .modifier,
                    rgbLightingEnabled: rgbLightingEnabled,
                    rgbPhase: rgbPhase
                ) {
                    layer = layer == .letters ? .numbers : .letters
                    if layer == .letters {
                        updateAutomaticShift()
                    }
                }
                .frame(width: 52)

                if let onNextKeyboard {
                    KeyButton(
                        label: "globe",
                        accessibilityLabel: "Next Keyboard",
                        isSystemImage: true,
                        kind: .modifier,
                        rgbLightingEnabled: rgbLightingEnabled,
                        rgbPhase: rgbPhase,
                        action: onNextKeyboard
                    )
                        .frame(width: 44)
                }

                if let contextualKey = contextualKey() {
                    KeyButton(
                        label: contextualKey,
                        kind: .modifier,
                        rgbLightingEnabled: rgbLightingEnabled,
                        rgbPhase: rgbPhase
                    ) {
                        perform([.insert(contextualKey)])
                    }
                    .frame(width: contextualKey == ".com" ? 56 : 40)
                }

                SpaceKey(
                    rgbLightingEnabled: rgbLightingEnabled,
                    rgbPhase: rgbPhase,
                    onSpace: insertSpace,
                    onMoveCursor: { perform([.moveCursor($0)]) },
                    onCursorModeChanged: { isCursorModeActive = $0 }
                )
                KeyButton(
                    label: returnKeyLabel(),
                    kind: .modifier,
                    rgbLightingEnabled: rgbLightingEnabled,
                    rgbPhase: rgbPhase
                ) {
                    perform([.insert("\n")])
                    shiftState = autoCapitalizationEnabled ? .on : .off
                }
                .frame(width: 72)
            }
        }
        .background {
            if rgbLightingEnabled {
                RGBLightingBackdrop(phase: rgbPhase)
                    .padding(-3)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: rgbLightingEnabled)
        .animation(.spring(response: 0.3, dampingFraction: 0.86), value: layer)
    }

    private func updatePreferredHeight() {
        onPreferredHeightChange(
            KeyboardBehavior.preferredHeight(
                isResultVisible: selectedAction != nil || encryptedText != nil,
                includesNumberRow: layer == .letters
            )
        )
    }

    private var characterKeysEnabled: Bool {
        KeyboardBehavior.characterKeysEnabled(
            isCursorModeActive: isCursorModeActive
        )
    }

    private func select(_ action: AIAction) {
        Haptics.tap()
        copied = false
        encryptionNotice = nil
        encryptedText = nil
        guard LocalAIEngine.state == .ready else {
            selectedAction = nil
            encryptionNotice = LocalAIEngine.state.label
            return
        }
        if selectedAction == action {
            selectedAction = nil
        } else {
            selectedAction = action
            generate(for: action)
        }
    }

    private func toolbarLabel(
        title: String,
        symbol: String,
        tint: Color,
        isSelected: Bool
    ) -> some View {
        HStack(spacing: 6) {
            Image(systemName: symbol)
                .font(.system(size: 11, weight: .semibold))
            Text(title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .foregroundStyle(isSelected ? tint : .white)
        .frame(maxWidth: .infinity)
        .frame(height: 44)
        .background(isSelected ? tint.opacity(0.10) : Color.clear)
        .clipShape(.rect(cornerRadius: 10))
        .keyboardGlass(
            .toolbar,
            tint: isSelected ? tint : TypeTheme.elevated
        )
        .overlay {
            if rgbLightingEnabled {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.red, lineWidth: 1.1)
                    .hueRotation(.degrees(
                        rgbPhase + KeyboardRGBAnimation.phaseOffset(for: title)
                    ))
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? tint.opacity(0.7) : Color.white.opacity(0.08))
            }
        }
        .shadow(color: isSelected ? tint.opacity(0.18) : .clear, radius: 8)
    }

    private func generateEncryptionResult() {
        do {
            guard let keyText = TiloqEncryptionKeyStore.load() else {
                encryptionNotice = "Set key text in TILOQ Settings"
                return
            }
            guard let original = KeyboardBehavior.encryptionSource(
                selectedText: selectedText()
            ) else {
                encryptionNotice = "Select text to encrypt"
                return
            }
            guard original.hasPrefix(TiloqTextEncryption.messagePrefix) == false else {
                encryptionNotice = "This text is already encrypted"
                return
            }
            encryptedText = try TiloqTextEncryption.encrypt(
                original,
                keyText: keyText
            )
            copied = false
            encryptionNotice = nil
        } catch {
            encryptedText = nil
            encryptionNotice = error.localizedDescription
        }
    }

    private func updateRGBAnimation() {
        guard rgbLightingEnabled && reduceMotion == false else {
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                rgbPhase = 0
            }
            return
        }

        withAnimation(
            .linear(duration: KeyboardRGBAnimation.duration)
                .repeatForever(autoreverses: false)
        ) {
            rgbPhase = 360
        }
    }

    private func displayed(_ key: String) -> String {
        guard layer == .letters else { return key }
        return shiftState.isUppercase ? key : key.lowercased()
    }

    private func insert(_ key: String) {
        let value = displayed(key)
        perform([.insert(value)])
        if shiftState == .on { shiftState = .off }
        if autoCapitalizationEnabled && ".!?".contains(value) { shiftState = .on }
    }

    private func insertAlternate(_ value: String) {
        perform([.insert(value)])
        if shiftState == .on { shiftState = .off }
    }

    private func insertSpace() {
        let context = typingContext()
        if autoCorrectionEnabled,
           let correction = KeyboardSuggestionEngine.correction(for: context) {
            typingSuggestions = []
            perform(
                KeyboardSuggestionEngine.replacementEdits(
                    suggestion: correction,
                    context: context
                )
            )
            return
        }

        let edits = KeyboardBehavior.spaceEdits(
            after: context,
            doubleSpacePeriodEnabled: periodShortcutEnabled
        )
        perform(edits)
        if autoCapitalizationEnabled,
           edits == [.deleteBackward, .insert(". ")] {
            shiftState = .on
        }
    }

    private func selectSuggestion(_ suggestion: String) {
        let edits = KeyboardSuggestionEngine.replacementEdits(
            suggestion: suggestion,
            context: typingContext()
        )
        typingSuggestions = []
        perform(edits)
        Haptics.tap()
    }

    private func perform(_ edits: [KeyboardEdit]) {
        edits.forEach(onEdit)
        refreshSuggestionsSoon()
    }

    private func refreshSuggestionsSoon() {
        Task { @MainActor in
            await Task.yield()
            refreshSuggestions()
        }
    }

    private func refreshSuggestions() {
        typingSuggestions = suggestionsEnabled
            ? KeyboardSuggestionEngine.suggestions(for: typingContext())
            : []
    }

    private func handleShift() {
        let now = Date.now
        if shiftState == .locked {
            shiftState = .off
        } else if capsLockEnabled && now.timeIntervalSince(lastShiftTap) < 0.35 {
            shiftState = .locked
        } else {
            shiftState = shiftState == .off ? .on : .off
        }
        lastShiftTap = now
    }

    private func updateAutomaticShift() {
        shiftState = autoCapitalizationEnabled
            && KeyboardBehavior.shouldCapitalize(after: typingContext())
            ? .on
            : .off
    }

    private func generate(for action: AIAction) {
        isGenerating = true
        generatedText = ""
        let source = sourceText().isEmpty ? TypeCopy.original : sourceText()
        Task {
            let response = await LocalAIEngine.shared.transform(source, action: action, tone: tone)
            await MainActor.run {
                guard selectedAction == action else { return }
                generatedText = response
                isGenerating = false
            }
        }
    }
}

private struct ResultPanel: View {
    let action: AIAction?
    let original: String
    let result: String
    let isGenerating: Bool
    @Binding var tone: RewriteTone
    @Binding var copied: Bool
    let onInsert: () -> Void

    private var tint: Color {
        action?.tint ?? TypeTheme.encryption
    }

    private var title: String {
        guard let action else { return "Encrypt" }
        return action == .grammar ? "Grammar Fix" : action.rawValue
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(tint)
                    .frame(width: 8, height: 8)
                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                Spacer()
                Text("ON DEVICE")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .tracking(1.5)
                    .foregroundStyle(.secondary)
            }

            if action == .grammar || action == nil {
                VStack(alignment: .leading, spacing: 4) {
                    Text(action == nil ? "Selected Text" : "Original")
                        .foregroundStyle(.secondary)
                    Text(original.isEmpty ? TypeCopy.original : original)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                .font(.system(size: 12, design: .rounded))
            }

            if isGenerating {
                HStack(spacing: 8) {
                    ProgressView()
                        .controlSize(.small)
                        .tint(tint)
                    Text("Thinking on device…")
                        .foregroundStyle(.secondary)
                }
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .frame(minHeight: 36)
            } else {
                Text(result)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(action == nil ? 3 : nil)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack(spacing: 8) {
                Button("Insert", action: onInsert)
                    .buttonStyle(ResultActionStyle(primary: true, tint: tint))
                    .disabled(isGenerating)

                Button {
                    UIPasteboard.general.string = result
                    copied = true
                    Haptics.success()
                } label: {
                    Text(copied ? "Copied" : "Copy")
                }
                .buttonStyle(ResultActionStyle(primary: false, tint: tint))
                .disabled(isGenerating)

                if action == .rewrite {
                    Menu {
                        Picker("Tone", selection: $tone) {
                            ForEach(RewriteTone.allCases) { tone in
                                Text(tone.rawValue).tag(tone)
                            }
                        }
                    } label: {
                        Label(tone.rawValue, systemImage: "chevron.down")
                            .labelStyle(TrailingIconLabelStyle())
                    }
                    .buttonStyle(ResultActionStyle(primary: false, tint: tint))
                } else if action == .improve {
                    Menu {
                        ForEach(RewriteTone.allCases) { tone in
                            Button(tone.rawValue) { self.tone = tone }
                        }
                    } label: {
                        Text("Change tone")
                    }
                    .buttonStyle(ResultActionStyle(primary: false, tint: tint))
                }
            }
        }
        .padding(12)
        .background(Color.clear)
        .clipShape(.rect(cornerRadius: 10))
        .keyboardGlass(.result, tint: TypeTheme.surface)
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(tint.opacity(0.3))
        }
    }

}

private struct ResultActionStyle: ButtonStyle {
    let primary: Bool
    let tint: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .semibold, design: .rounded))
            .foregroundStyle(primary ? Color.black : Color.white)
            .padding(.horizontal, 12)
            .frame(height: 32)
            .background(primary ? tint : TypeTheme.elevated)
            .clipShape(.rect(cornerRadius: 8))
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .offset(y: configuration.isPressed ? 1 : 0)
            .animation(.spring(response: 0.2, dampingFraction: 0.65), value: configuration.isPressed)
    }
}

private struct TrailingIconLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 4) {
            configuration.title
            configuration.icon
                .font(.system(size: 9, weight: .bold))
        }
    }
}
