# TILOQ 1.0 Release Checklist

## Developer account

- [ ] Enroll the publishing legal entity in the Apple Developer Program.
- [ ] Accept current agreements in App Store Connect.
- [ ] Create/confirm App IDs `com.tiloq.app` and `com.tiloq.app.keyboard`.
- [ ] Create/confirm App Group `group.com.tiloq.app` and enable it for both identifiers.
- [ ] Create an Apple Distribution certificate and App Store provisioning profiles.

## Store record

- [ ] Create the app record with the name TILOQ and bundle ID `com.tiloq.app`.
- [ ] Paste and proofread `metadata.md`.
- [ ] Replace every bracketed placeholder.
- [ ] Host `privacy-policy.html` at a public HTTPS URL.
- [ ] Provide a working public Support URL.
- [ ] Complete age-rating and content-rights questions.
- [ ] Complete Apple's encryption/export-compliance questionnaire accurately for CryptoKit AES-GCM. Do not declare an exemption without confirming the applicable classification.
- [ ] Complete App Privacy as Data Not Collected only if the final binary still matches `privacy.md`.

## Media

- [ ] Capture required iPhone screenshots at an accepted App Store Connect size.
- [ ] Include Setup, selected-text Grammar, Rewrite tone, Improve, Settings privacy, and Decrypt flows.
- [ ] Keep screenshots honest: use an Apple Intelligence-ready physical device for generated results.
- [ ] Review the 1024 × 1024 App Store icon for legibility and absence of transparency.

## Quality

- [ ] Run all unit tests.
- [ ] Test typing, space, return, shift/caps lock, numbers, symbols, globe, cursor mode, key previews, suggestions, long-press characters, and repeating delete.
- [ ] Test the keyboard in Messages, Mail, Notes, and Safari.
- [ ] Test on the smallest and largest supported iPhone displays for cropping.
- [ ] Confirm Full Access is not requested and the keyboard works without it.
- [ ] Test Apple Intelligence unavailable, disabled, preparing, successful, and error states.
- [ ] Test encryption round trip, wrong key, malformed text, and tampering.
- [ ] Verify VoiceOver labels, Dynamic Type, Reduce Motion, and sufficient contrast.
- [ ] Upload to TestFlight and complete internal testing before review.

## Submission

- [ ] Increment `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` for every submitted build.
- [ ] Archive with the Release configuration and Apple Distribution signing.
- [ ] Validate and upload from Xcode Organizer.
- [ ] Add `review-notes.md` to App Review Information.
- [ ] Attach a review contact and respond to review questions promptly.
