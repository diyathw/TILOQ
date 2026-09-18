import SwiftUI

struct KeyboardBehaviorControls: View {
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
    @AppStorage(TiloqSettings.numberRowKey, store: TiloqSettings.sharedDefaults)
    private var numberRowEnabled = false

    var body: some View {
        VStack(spacing: 0) {
            Toggle("Key Preview", isOn: $keyPreviewEnabled)
                .keyboardSettingsRow()
            rowDivider
            Toggle("Auto-Capitalization", isOn: $autoCapitalizationEnabled)
                .keyboardSettingsRow()
            rowDivider
            Toggle("Suggestions", isOn: $suggestionsEnabled)
                .keyboardSettingsRow()
            rowDivider
            Toggle("Auto-Correction", isOn: $autoCorrectionEnabled)
                .keyboardSettingsRow()
            rowDivider
            Toggle("Enable Caps Lock", isOn: $capsLockEnabled)
                .keyboardSettingsRow()
            rowDivider
            Toggle("“.” Shortcut", isOn: $periodShortcutEnabled)
                .keyboardSettingsRow()
            rowDivider
            Toggle("Number Row", isOn: $numberRowEnabled)
                .keyboardSettingsRow()
                .accessibilityHint("Shows a permanent number row above the letter keys. Numbers are always available via the 123 key regardless of this setting.")
        }
    }

    private var rowDivider: some View {
        Divider()
            .padding(.leading, 8)
            .opacity(0.65)
    }
}

private extension View {
    func keyboardSettingsRow() -> some View {
        frame(minHeight: 44)
            .padding(.vertical, 5)
    }
}
