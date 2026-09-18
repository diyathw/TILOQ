---
description: Run a security and privacy audit of TILOQ against OWASP MASVS and the repo's privacy invariants
---

Dispatch the `ios-security-reviewer` agent against the current uncommitted changes (or `$ARGUMENTS` if given — e.g. a branch, or "full repo" for a standing audit rather than a diff-scoped one).

Before dispatching, do the cheap, deterministic checks yourself so the agent isn't wasting a pass on things a grep already answers:

```sh
grep -rn "URLSession\|URLRequest\|Alamofire" TiloqApp Shared KeyboardExtension
grep -rn "UserDefaults.standard" TiloqApp Shared KeyboardExtension
plutil -lint TiloqApp/TiloqApp.entitlements KeyboardExtension/TypeKeyboard.entitlements
plutil -lint TiloqApp/PrivacyInfo.xcprivacy KeyboardExtension/PrivacyInfo.xcprivacy
grep -n "RequestsOpenAccess" KeyboardExtension/Info.plist
```

Any networking call found outside test code is an automatic blocker — surface it immediately rather than waiting for the full report.

Then have `ios-security-reviewer` apply its full OWASP MASVS checklist to the actual diff. Report findings ranked by severity using `docs/PLAN.md`'s scale (Blocker = privacy violation or encryption failure; High = broken core guarantee; Medium/Low below that). If nothing regresses, say so plainly — don't manufacture findings.
