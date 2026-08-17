import SwiftUI

struct KeyboardNumberRow: View {
    let rgbLightingEnabled: Bool
    let rgbPhase: Double
    let showsKeyPreview: Bool
    let isEnabled: Bool
    let onInsert: (String) -> Void

    var body: some View {
        HStack(spacing: 6) {
            ForEach(KeyboardLayer.numberShortcutRow, id: \.self) { number in
                KeyButton(
                    label: number,
                    isEnabled: isEnabled,
                    rgbLightingEnabled: rgbLightingEnabled,
                    rgbPhase: rgbPhase,
                    showsKeyPreview: showsKeyPreview
                ) {
                    onInsert(number)
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Number row")
    }
}
