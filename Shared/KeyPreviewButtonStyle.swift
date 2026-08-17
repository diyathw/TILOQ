import SwiftUI

struct KeyPreviewButtonStyle: ButtonStyle {
    let preview: String
    let showsPreview: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .brightness(configuration.isPressed ? -0.08 : 0)
            .offset(y: configuration.isPressed ? 2 : 0)
            .shadow(
                color: .black.opacity(configuration.isPressed ? 0.15 : 0.45),
                radius: configuration.isPressed ? 1 : 3,
                y: configuration.isPressed ? 1 : 3
            )
            .overlay(alignment: .top) {
                if configuration.isPressed && showsPreview {
                    VStack(spacing: -4) {
                        Text(preview)
                            .font(.title.weight(.medium))
                            .foregroundStyle(.white)
                            .frame(width: 54, height: 58)
                            .background(TypeTheme.elevated)
                            .clipShape(.rect(cornerRadius: 11))
                            .overlay {
                                RoundedRectangle(cornerRadius: 11)
                                    .stroke(Color.white.opacity(0.14))
                            }
                            .shadow(color: .black.opacity(0.5), radius: 8, y: 4)
                        RoundedRectangle(cornerRadius: 2)
                            .fill(TypeTheme.elevated)
                            .frame(width: 18, height: 10)
                    }
                    .offset(y: -65)
                    .transition(.opacity.combined(with: .scale(scale: 0.9, anchor: .bottom)))
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
                }
            }
            .zIndex(configuration.isPressed && showsPreview ? 100 : 0)
            .animation(
                reduceMotion ? .none : .spring(response: 0.18, dampingFraction: 0.72),
                value: configuration.isPressed
            )
    }
}
