import SwiftUI

struct KeyboardSuggestionBar: View {
    let suggestions: [String]
    let isEnabled: Bool
    let rgbLightingEnabled: Bool
    let rgbPhase: Double
    let statusMessage: String?
    let onSelect: (String) -> Void

    var body: some View {
        HStack(spacing: 6) {
            if let statusMessage {
                Label(statusMessage, systemImage: "lock.shield.fill")
                    .font(.caption)
                    .foregroundStyle(TypeTheme.grammar)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .frame(maxWidth: .infinity)
            } else if suggestions.isEmpty {
                Label(
                    isEnabled ? "On-device suggestions" : "Suggestions off",
                    systemImage: isEnabled ? "lock.fill" : "text.badge.xmark"
                )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            } else {
                ForEach(suggestions, id: \.self) { suggestion in
                    Button(suggestion) {
                        onSelect(suggestion)
                    }
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .frame(maxWidth: .infinity)
                    .frame(height: 34)
                    .background(Color.clear)
                    .clipShape(.rect(cornerRadius: 8))
                    .keyboardGlass(.suggestion, tint: TypeTheme.elevated)
                    .overlay {
                        if rgbLightingEnabled {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.red, lineWidth: 1)
                                .hueRotation(.degrees(
                                    rgbPhase + KeyboardRGBAnimation.phaseOffset(for: suggestion)
                                ))
                        } else {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white.opacity(0.08))
                        }
                    }
                    .buttonStyle(TactileButtonStyle())
                    .accessibilityHint("Replaces the current word")
                }
            }
        }
        .frame(height: 34)
    }
}
