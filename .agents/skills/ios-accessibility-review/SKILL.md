---
name: ios-accessibility-review
description: Reviews TILOQ UI changes for VoiceOver, Dynamic Type, contrast, Reduce Motion, and touch-target regressions against Apple HIG. Use on any SwiftUI/UIKit view change, and especially on anything touching the keyboard extension's layout or the app's settings screens.
---

Accessibility is a release requirement for TILOQ, not optional polish (`AGENTS.md`, "Keep touch targets accessible and provide meaningful VoiceOver labels and hints"). Follow Apple's Human Interface Guidelines as the baseline.

## What to check on every UI diff

- **VoiceOver**: every interactive control needs either a self-describing native label (SF Symbol buttons especially) or an explicit `.accessibilityLabel`/`.accessibilityHint`. Check new `KeyButton`, toolbar, and settings controls the way existing ones do (e.g. the shift key's `accessibilityLabel: shiftState == .locked ? "Caps Lock" : "Shift"`, the globe key's `"Next Keyboard"`, the privacy link's `.accessibilityHint`).
- **Dynamic Type**: text must scale. Flag any new hard-coded pixel font that opts out of scaling without a documented reason (the keyboard's own key glyphs are a deliberate, justified exception — everything in `TiloqApp`'s settings/setup/decryption screens is not). If a layout was previously verified to survive Dynamic Type and this diff changes it, re-verify at at least one accessibility text size — this app has a real, previously-hit bug class where oversized text pushes fixed-height content off-screen (see the `KeyboardDemoView` tab-bar-overlap fix); don't reintroduce it.
- **Contrast**: no state communicated by color alone (e.g. a locked/unlocked, on/off, or success/failure state needs a symbol or label change too, not just a tint change). Check contrast holds in both the dark industrial theme and Increased Contrast. Note the RGB-lighting and custom-photo-backdrop paywall lock icons already pair a symbol with the tint change — keep that pattern for any new gated feature.
- **Reduce Motion**: any new animation (RGB lighting, transitions, haptics-adjacent visual feedback) must respect `@Environment(\.accessibilityReduceMotion)` the way `TypeKeyboardView`'s `reduceMotion` already gates the RGB animation. A new animation that ignores this environment value is a regression.
- **Touch targets**: keyboard keys and toolbar buttons must stay at least Apple's minimum tappable size; check new/resized controls (`.frame(width:)` on `KeyButton` variants) don't shrink below what's already established.
- **Focus order**: for any new multi-control screen (settings sections, setup steps), check VoiceOver's swipe order matches visual/reading order — flag a `ZStack`/overlay arrangement that would scramble it.
- **Haptics**: respect the haptics setting (`TiloqSettings.hapticsKey`) — new haptic feedback must be gated the same way existing `Haptics.tap()`/`.success()` calls are, not unconditional.

## How to verify, not just read

Where feasible, actually exercise the change: run the app/extension in Simulator with a larger Dynamic Type size (`xcrun simctl ui <device> content_size accessibility-extra-extra-extra-large`) and/or Increase Contrast (`xcrun simctl ui <device> increase_contrast enabled`), screenshot, and look — don't assume a layout survives just because the code looks plausible. `AGENTS.md` explicitly requires testing both the result-panel and normal keyboard states, including the number row, for exactly this reason.

## Output

For each finding: the concrete accessibility failure (what a VoiceOver user, low-vision user, or Reduce-Motion user actually hits), file:line, and the smallest fix — usually adding a label/hint, gating an animation, or fixing a `.frame` size, not a redesign.
