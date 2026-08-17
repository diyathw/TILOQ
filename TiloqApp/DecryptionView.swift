import SwiftUI
import UIKit

struct DecryptionView: View {
    @State private var encryptedText = ""
    @State private var keyText = ""
    @State private var decryptedText = ""
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Label("Decrypt TILOQ Text", systemImage: "lock.open.fill")
                    .font(.title2.bold())
                    .foregroundStyle(TypeTheme.grammar)

                Text("Paste the encrypted TILOQ1 text and enter the same key text used by the sender.")
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 8) {
                    Text("ENCRYPTED TEXT")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("TILOQ1…", text: $encryptedText, axis: .vertical)
                        .lineLimit(4...8)
                        .font(.system(.footnote, design: .monospaced))
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding(12)
                        .background(Color.secondary.opacity(0.10))
                        .clipShape(.rect(cornerRadius: 10))
                    Button("Paste Encrypted Text", systemImage: "doc.on.clipboard") {
                        encryptedText = UIPasteboard.general.string ?? ""
                    }
                    .font(.subheadline)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("KEY TEXT")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    SecureField("Enter key text", text: $keyText)
                        .font(.system(.footnote, design: .monospaced))
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding(12)
                        .background(Color.secondary.opacity(0.10))
                        .clipShape(.rect(cornerRadius: 10))
                    Button("Paste Key", systemImage: "key.horizontal") {
                        keyText = UIPasteboard.general.string ?? ""
                    }
                    .font(.subheadline)
                }

                Button("Decrypt", systemImage: "lock.open", action: decrypt)
                    .buttonStyle(.borderedProminent)
                    .tint(TypeTheme.grammar)
                    .frame(maxWidth: .infinity)

                if let errorMessage {
                    Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                        .font(.footnote)
                        .foregroundStyle(.orange)
                }

                if decryptedText.isEmpty == false {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("DECRYPTED MESSAGE")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(decryptedText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .textSelection(.enabled)
                        Button("Copy Message", systemImage: "doc.on.doc") {
                            UIPasteboard.general.string = decryptedText
                        }
                    }
                    .padding(16)
                    .keyboardGlass(.result, tint: TypeTheme.surface)
                }
            }
            .padding(20)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Decrypt")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            loadSavedKey()
        }
    }

    private func loadSavedKey() {
        keyText = TiloqEncryptionKeyStore.load() ?? ""
    }

    private func decrypt() {
        do {
            decryptedText = try TiloqTextEncryption.decrypt(
                encryptedText,
                keyText: keyText
            )
            errorMessage = nil
            Haptics.success()
        } catch {
            decryptedText = ""
            errorMessage = error.localizedDescription
        }
    }
}
