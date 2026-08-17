import SwiftUI
import UIKit

struct SetupGuideView: View {
    let onTryKeyboard: () -> Void
    @Environment(\.openURL) private var openURL

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    SetupHeroView()

                    VStack(alignment: .leading, spacing: 12) {
                        Text("SET UP THE KEYBOARD")
                            .font(.caption)
                            .tracking(1.5)
                            .foregroundStyle(.secondary)
                            .padding(.leading, 16)

                        ForEach(SetupGuideContent.steps) { step in
                            SetupStepCard(step: step)
                        }
                    }

                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "lock.shield.fill")
                            .font(.title3)
                            .foregroundStyle(TypeTheme.rewrite)
                            .accessibilityHidden(true)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Full Access stays off")
                                .font(.headline)
                            Text("Apple Intelligence runs locally. TILOQ does not need permission to send your writing anywhere.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(16)
                    .background(TypeTheme.rewrite.opacity(0.1))
                    .clipShape(.rect(cornerRadius: 10))
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 120)
            }
            .background(Color.black)
            .navigationTitle("Setup")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 8) {
                    Button("Open iPhone Settings", systemImage: "gear", action: openSettings)
                        .buttonStyle(.borderedProminent)
                        .tint(TypeTheme.rewrite)
                        .foregroundStyle(.black)
                        .controlSize(.large)
                        .frame(maxWidth: .infinity)

                    Button("Try TILOQ", systemImage: "keyboard", action: onTryKeyboard)
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
            }
        }
    }

    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        openURL(url)
    }
}
