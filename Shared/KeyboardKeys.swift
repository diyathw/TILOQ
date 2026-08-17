import SwiftUI

enum KeyKind {
    case letter
    case modifier
}

struct KeyButton: View {
    let label: String
    var accessibilityLabel: String? = nil
    var isSystemImage = false
    var kind: KeyKind = .letter
    var isSelected = false
    var isEnabled = true
    var rgbLightingEnabled = false
    var rgbPhase = 0.0
    var showsKeyPreview = false
    var alternateCharacters: [String] = []
    var alternateAction: ((String) -> Void)? = nil
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.tap()
            action()
        } label: {
            Group {
                if isSystemImage {
                    Image(systemName: label)
                        .font(.system(size: 16, weight: .medium))
                } else {
                    Text(label)
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                }
            }
            .foregroundStyle(isSelected ? TypeTheme.rewrite : .white)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(isSelected ? TypeTheme.rewrite.opacity(0.12) : Color.clear)
            .clipShape(.rect(cornerRadius: 7))
            .keyboardGlass(
                kind == .letter ? .key : .modifier,
                tint: isSelected ? TypeTheme.rewrite : background
            )
            .overlay {
                if rgbLightingEnabled {
                    RoundedRectangle(cornerRadius: 7)
                        .stroke(Color.red, lineWidth: 1.15)
                        .shadow(color: .red.opacity(0.28), radius: 2)
                        .hueRotation(.degrees(
                            rgbPhase + KeyboardRGBAnimation.phaseOffset(for: label)
                        ))
                } else {
                    RoundedRectangle(cornerRadius: 7)
                        .stroke(isSelected ? TypeTheme.rewrite.opacity(0.7) : Color.white.opacity(0.08))
                }
            }
        }
        .buttonStyle(
            KeyPreviewButtonStyle(
                preview: label,
                showsPreview: showsKeyPreview && kind == .letter && isSystemImage == false
            )
        )
        .contextMenu {
            ForEach(alternateCharacters, id: \.self) { character in
                Button(character) {
                    Haptics.tap()
                    alternateAction?(character)
                }
            }
        }
        .accessibilityLabel(accessibilityLabel ?? label)
        .accessibilityHint(
            alternateCharacters.isEmpty ? "" : "Touch and hold for alternate characters"
        )
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .disabled(isEnabled == false)
        .opacity(isEnabled ? 1 : 0.24)
        .animation(.easeOut(duration: 0.12), value: isEnabled)
    }

    private var background: Color {
        kind == .letter ? TypeTheme.key : TypeTheme.secondaryKey
    }
}

struct RepeatingDeleteKey: View {
    let rgbLightingEnabled: Bool
    let rgbPhase: Double
    let action: () -> Void
    @State private var repeatTask: Task<Void, Never>?
    @State private var isPressing = false

    var body: some View {
        Button("Delete", systemImage: "delete.left", action: deleteOnce)
            .labelStyle(.iconOnly)
            .font(.system(size: 16, weight: .medium))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(Color.clear)
            .clipShape(.rect(cornerRadius: 7))
            .keyboardGlass(.modifier, tint: TypeTheme.secondaryKey)
            .overlay {
                if rgbLightingEnabled {
                    RoundedRectangle(cornerRadius: 7)
                        .stroke(Color.red, lineWidth: 1.15)
                        .shadow(color: .red.opacity(0.28), radius: 2)
                        .hueRotation(.degrees(
                            rgbPhase + KeyboardRGBAnimation.phaseOffset(for: "delete")
                        ))
                } else {
                    RoundedRectangle(cornerRadius: 7).stroke(Color.white.opacity(0.08))
                }
            }
            .buttonStyle(TactileButtonStyle())
            .highPriorityGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in startPressing() }
                    .onEnded { _ in stopRepeating() }
            )
            .onDisappear(perform: stopRepeating)
    }

    private func deleteOnce() {
        Haptics.tap()
        action()
    }

    private func startPressing() {
        guard isPressing == false else { return }
        isPressing = true
        deleteOnce()
        repeatTask?.cancel()
        repeatTask = Task { @MainActor in
            do {
                try await Task.sleep(for: .milliseconds(350))
            } catch {
                return
            }

            while Task.isCancelled == false {
                action()
                do {
                    try await Task.sleep(for: .milliseconds(75))
                } catch {
                    return
                }
            }
        }
    }

    private func stopRepeating() {
        isPressing = false
        repeatTask?.cancel()
        repeatTask = nil
    }
}

struct SpaceKey: View {
    let rgbLightingEnabled: Bool
    let rgbPhase: Double
    let onSpace: () -> Void
    let onMoveCursor: (Int) -> Void
    let onCursorModeChanged: (Bool) -> Void
    @State private var lastStep = 0
    @State private var didMoveCursor = false

    var body: some View {
        Button("space", action: insertSpace)
            .font(.system(size: 15, weight: .regular, design: .rounded))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(Color.clear)
            .clipShape(.rect(cornerRadius: 7))
            .keyboardGlass(.key, tint: TypeTheme.key)
            .overlay {
                if rgbLightingEnabled {
                    RoundedRectangle(cornerRadius: 7)
                        .stroke(Color.red, lineWidth: 1.15)
                        .shadow(color: .red.opacity(0.28), radius: 2)
                        .hueRotation(.degrees(
                            rgbPhase + KeyboardRGBAnimation.phaseOffset(for: "space")
                        ))
                } else {
                    RoundedRectangle(cornerRadius: 7).stroke(Color.white.opacity(0.08))
                }
            }
            .contentShape(.rect)
            .buttonStyle(TactileButtonStyle())
            .highPriorityGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged(handleDrag)
                    .onEnded(handleRelease)
            )
            .accessibilityHint("Double-space adds a period. Drag to move the cursor.")
            .onDisappear {
                onCursorModeChanged(false)
            }
    }

    private func insertSpace() {
        Haptics.tap()
        onSpace()
    }

    private func handleDrag(_ value: DragGesture.Value) {
        let step = Int(value.translation.width / 18)
        let change = step - lastStep
        guard change != 0 else { return }
        lastStep = step
        if didMoveCursor == false {
            onCursorModeChanged(true)
        }
        didMoveCursor = true
        onMoveCursor(change)
        Haptics.tap()
    }

    private func handleRelease(_: DragGesture.Value) {
        if KeyboardBehavior.shouldInsertSpace(afterCursorDrag: didMoveCursor) {
            insertSpace()
        }
        onCursorModeChanged(false)
        lastStep = 0
        didMoveCursor = false
    }
}
