import SwiftUI

struct RGBLightingBackdrop: View {
    let phase: Double

    var body: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(spectrum(angle: phase).opacity(0.16))
            .blur(radius: 7)
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(spectrum(angle: phase).opacity(0.72), lineWidth: 1)
            }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func spectrum(angle: Double) -> AngularGradient {
        AngularGradient(
            colors: [.red, .orange, .yellow, .green, .cyan, .blue, .purple, .red],
            center: .center,
            angle: .degrees(angle)
        )
    }
}
