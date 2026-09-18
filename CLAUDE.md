# CLAUDE.md

@AGENTS.md

## Engineering governance

`AGENTS.md` above is the binding contract for this repo — product intent, privacy/security invariants, keyboard behavior invariants, Swift conventions, TDD workflow, and build/release process. Follow it for all work here.

For structured review passes, this repo also defines specialized subagents and slash commands under `.claude/`:

- `.claude/agents/ios-architect.md` — architecture, boundaries, Swift Concurrency isolation
- `.claude/agents/ios-reviewer.md` — general Swift/SwiftUI correctness, API design, performance
- `.claude/agents/ios-test-engineer.md` — TDD workflow enforcement, coverage gaps
- `.claude/agents/ios-security-reviewer.md` — OWASP MASVS privacy/security review
- `.claude/agents/ios-accessibility-reviewer.md` — VoiceOver, Dynamic Type, HIG compliance
- `.claude/agents/app-store-reviewer.md` — versioning, privacy manifests, App Store readiness
- Slash commands `/ios-review`, `/ios-test`, `/ios-security`, `/appstore-check` orchestrate the above against the current diff.
- `.claude/settings.json` allowlists safe, read-only/developer-productivity commands (git reads, `xcodebuild build/test`, `agvtool`, `simctl`, `devicectl`, `plutil -lint`) and explicitly denies irreversible ones (force-push, `reset --hard`, `rm -rf`, archive/export, codesign, notarization) regardless of prompting.

Use these proactively before considering a non-trivial change done — don't wait to be asked.

## Build number versioning

The project uses Apple's `apple-generic` versioning system (`VERSIONING_SYSTEM` build setting). Bump the build number with `xcrun agvtool next-version -all` — do not hand-edit `CURRENT_PROJECT_VERSION` in `project.pbxproj`. Every new binary uploaded to App Store Connect (TestFlight or release) needs a strictly higher build number than the last, regardless of how minor the change is; `MARKETING_VERSION` only changes when explicitly asked.
