import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        List {
            Section {
                Label("100% Private", systemImage: "lock.shield.fill")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(TypeTheme.rewrite)
                Text("TILOQ does not collect, sell, or track personal data. Your writing is not sent to TILOQ servers.")
            }

            privacySection(
                "Writing & Apple Intelligence",
                text: "Rewrite, Grammar, and Improve use Apple Intelligence on your device. If the local model is unavailable, TILOQ leaves your selected text unchanged."
            )
            privacySection(
                "Keyboard Data",
                text: "Keyboard preferences, your optional backdrop, and encryption key text are stored locally in TILOQ's shared app container so the app and keyboard can use the same settings."
            )
            privacySection(
                "Encryption",
                text: "Encryption uses AES-GCM with the key text you provide. TILOQ has no account recovery and cannot recover a lost key. Share keys separately and only with people you trust."
            )
            privacySection(
                "Clipboard",
                text: "TILOQ reads or writes the clipboard only after you tap a Paste or Copy control."
            )
            privacySection(
                "Your Control",
                text: "You can turn off the keyboard in iOS Settings or remove locally stored TILOQ data by deleting the app."
            )

            Section {
                LabeledContent("Last updated", value: "August 17, 2026")
            }
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func privacySection(_ title: String, text: String) -> some View {
        Section(title) {
            Text(text)
        }
    }
}
