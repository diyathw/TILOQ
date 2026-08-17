import SwiftUI

struct ContentView: View {
    @State private var selectedTab = AppTab.setup

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Setup", systemImage: "checklist", value: .setup) {
                SetupGuideView { selectedTab = .keyboard }
            }

            Tab("Try TILOQ", systemImage: "keyboard", value: .keyboard) {
                KeyboardDemoView()
            }

            Tab("Decrypt", systemImage: "lock.open.fill", value: .decrypt) {
                NavigationStack {
                    DecryptionView()
                }
            }

            Tab("Settings", systemImage: "slider.horizontal.3", value: .settings) {
                SettingsView()
            }
        }
        .tint(TypeTheme.rewrite)
    }
}

private struct KeyboardDemoView: View {
    @State private var message = TypeCopy.original

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("MESSAGE")
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .tracking(1.5)
                                .foregroundStyle(.secondary)
                            Text("Alex")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                        }
                        Spacer()
                        Label("Local", systemImage: "lock.fill")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(TypeTheme.rewrite)
                    }

                    Group {
                        if message == TypeCopy.original {
                            ProofreadSample()
                        } else {
                            Text(message)
                        }
                    }
                    .font(.system(size: 18, weight: .regular, design: .rounded))
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .clipShape(.rect(cornerRadius: 10))

                    Text("Select the sentence, then choose one focused action.")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                .padding(20)

                Spacer(minLength: 8)

                TypeKeyboardView(
                    sourceText: { message },
                    selectedText: { message },
                    typingContext: { message },
                    onSuggestion: { message = $0 },
                    onEdit: { edit in
                        KeyboardBehavior.applying(edit, to: &message)
                    },
                    onNextKeyboard: nil,
                    contextualKey: { nil },
                    returnKeyLabel: { "return" },
                    onPreferredHeightChange: { _ in }
                )
            }
            .background(TypeTheme.background)
            .navigationTitle("TILOQ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Reset") { message = TypeCopy.original }
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                }
            }
        }
    }
}

private struct ProofreadSample: View {
    var body: some View {
        Text("i \(Text("defenetely").underline(color: .red)) will be there \(Text("tommorow").underline(color: .red)), \(Text("cant").underline(color: .red)) wait to see you and \(Text("discuss about").underline(color: .red)) the project.")
    }
}

private struct SettingsView: View {
    private enum Destination: Hashable {
        case privacy
    }

    @AppStorage(TiloqSettings.rewriteEnabledKey, store: TiloqSettings.sharedDefaults)
    private var rewriteEnabled = true
    @AppStorage(TiloqSettings.grammarEnabledKey, store: TiloqSettings.sharedDefaults)
    private var grammarEnabled = true
    @AppStorage(TiloqSettings.improveEnabledKey, store: TiloqSettings.sharedDefaults)
    private var improveEnabled = true
    @AppStorage(TiloqSettings.hapticsKey, store: TiloqSettings.sharedDefaults)
    private var hapticsEnabled = true
    @AppStorage(TiloqSettings.defaultToneKey, store: TiloqSettings.sharedDefaults)
    private var defaultTone = RewriteTone.casual.rawValue

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    privacyHero
                    featureGrid
                    settings
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("TILOQ")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Destination.self) { destination in
                switch destination {
                case .privacy:
                    PrivacyPolicyView()
                }
            }
        }
    }

    private var privacyHero: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(TypeTheme.rewrite)
            Text("100% Private")
                .font(.system(size: 32, weight: .light, design: .rounded))
            Text("Write. Fix. Done.")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
            Text("All writing processing happens on your device.")
                .font(.system(size: 15, design: .rounded))
                .foregroundStyle(.secondary)
            Label(LocalAIEngine.state.label, systemImage: LocalAIEngine.state == .ready ? "checkmark.circle.fill" : "info.circle.fill")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(LocalAIEngine.state == .ready ? TypeTheme.rewrite : .orange)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 24)
    }

    private var featureGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
            FeatureCard(icon: "wifi.slash", title: "Offline & Private", detail: "Works without sending your writing to a server.")
            FeatureCard(icon: "apple.intelligence", title: "Local AI Engine", detail: "Fast Apple Intelligence processing on device.")
            FeatureCard(icon: "bolt.fill", title: "Instant", detail: "Grammar and rewrite suggestions appear quickly.")
            FeatureCard(icon: "square.stack.3d.up.fill", title: "Works Everywhere", detail: "Messages, Mail, Notes, Safari, and more.")
        }
    }

    private var settings: some View {
        VStack(alignment: .leading, spacing: 24) {
            SettingsSection(title: "AI TOOLS") {
                Toggle("Rewrite", isOn: $rewriteEnabled)
                Divider().padding(.leading, 16)
                Toggle("Grammar Fix", isOn: $grammarEnabled)
                Divider().padding(.leading, 16)
                Toggle("Improve", isOn: $improveEnabled)
            }

            SettingsSection(title: "WRITING") {
                HStack {
                    Text("Default Rewrite Tone")
                    Spacer()
                    Picker("Default Rewrite Tone", selection: $defaultTone) {
                        ForEach(RewriteTone.allCases) { tone in
                            Text(tone.rawValue).tag(tone.rawValue)
                        }
                    }
                    .labelsHidden()
                }
                Divider().padding(.leading, 16)
                Toggle("Haptic Feedback", isOn: $hapticsEnabled)
            }

            SettingsSection(title: "KEYBOARD") {
                KeyboardBehaviorControls()
            }

            SettingsSection(title: "APPEARANCE") {
                KeyboardAppearanceControls()
            }

            SettingsSection(title: "ENCRYPTION") {
                EncryptionSettingsControls()
            }

            SettingsSection(title: "ON DEVICE") {
                StatusRow(title: "Local Model", value: LocalAIEngine.state == .ready ? "Ready" : "Unavailable", positive: LocalAIEngine.state == .ready)
                Divider().padding(.leading, 16)
                StatusRow(title: "Processing", value: "On Device", positive: true)
            }

            SettingsSection(title: "ABOUT") {
                NavigationLink(value: Destination.privacy) {
                    Label("Privacy Policy", systemImage: "hand.raised.fill")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .accessibilityHint("Opens TILOQ's privacy policy")
            }
        }
        .font(.system(size: 15, design: .rounded))
    }
}

private struct FeatureCard: View {
    let icon: String
    let title: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(TypeTheme.rewrite)
            Text(title)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
            Text(detail)
                .font(.system(size: 12, design: .rounded))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, minHeight: 112, alignment: .topLeading)
        .padding(16)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 10))
    }
}

private struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .tracking(1.5)
                .foregroundStyle(.secondary)
                .padding(.leading, 16)
            VStack(spacing: 0) {
                content
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
            }
            .background(Color(uiColor: .secondarySystemBackground))
            .clipShape(.rect(cornerRadius: 10))
        }
        .tint(TypeTheme.rewrite)
    }
}

private struct StatusRow: View {
    let title: String
    let value: String
    let positive: Bool

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Label(value, systemImage: positive ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(positive ? TypeTheme.rewrite : .orange)
        }
    }
}
