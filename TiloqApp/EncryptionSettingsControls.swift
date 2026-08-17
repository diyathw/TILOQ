import SwiftUI
import UIKit

struct EncryptionSettingsControls: View {
    @AppStorage(
        TiloqSettings.encryptionEnabledKey,
        store: TiloqSettings.sharedDefaults
    ) private var encryptionEnabled = false
    @AppStorage(
        TiloqSettings.encryptionKeyTextKey,
        store: TiloqSettings.sharedDefaults
    ) private var keyText = ""
    @State private var isKeyVisible = false
    @State private var alertMessage = ""
    @State private var showsAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle("Encrypt Before Sending", isOn: $encryptionEnabled)

            Divider()

            HStack {
                Label("Shared Key Text", systemImage: "key.horizontal.fill")
                Spacer()
                Button(isKeyVisible ? "Hide" : "Reveal") {
                    isKeyVisible.toggle()
                }
            }

            Group {
                if isKeyVisible {
                    TextField("Enter your key text", text: $keyText, axis: .vertical)
                } else {
                    SecureField("Enter your key text", text: $keyText)
                }
            }
            .font(.system(.footnote, design: .monospaced))
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .padding(10)
            .background(Color.secondary.opacity(0.10))
            .clipShape(.rect(cornerRadius: 8))

            HStack {
                Button("Paste", systemImage: "doc.on.clipboard", action: pasteKey)
                Spacer()
                Button("Copy", systemImage: "doc.on.doc", action: copyKey)
            }
            .labelStyle(.titleAndIcon)
            .font(.subheadline)

            Label("Saved automatically", systemImage: "checkmark.circle.fill")
                .font(.footnote)
                .foregroundStyle(TypeTheme.rewrite)

            Text("Use any memorable string. Share the exact same text with people who need to decrypt your messages.")
                .font(.footnote)
                .foregroundStyle(.secondary)
            Text("Select text, then tap Encrypt beside the writing tools. TILOQ replaces only the selection; use the messaging app’s Send button afterward.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .alert("Encryption Key", isPresented: $showsAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }

    private func pasteKey() {
        guard let value = UIPasteboard.general.string else {
            show("The clipboard does not contain key text.")
            return
        }
        keyText = value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func copyKey() {
        guard keyText.isEmpty == false else { return }
        UIPasteboard.general.string = keyText
        show("Key copied. Share it through a separate trusted channel.")
    }

    private func show(_ message: String) {
        alertMessage = message
        showsAlert = true
    }
}
