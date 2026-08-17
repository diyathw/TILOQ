# App Privacy Answers

Based on the current 1.0 source, select **Data Not Collected** in App Store Connect.

The current project contains:

- no account system
- no analytics or advertising SDK
- no network requests
- no tracking
- no TILOQ server
- on-device Apple Intelligence processing
- local App Group preferences, backdrop data, and user-entered encryption key text
- clipboard access only after an explicit Copy or Paste action

Before every submission, search the source and dependencies again. If analytics, crash reporting, cloud sync, remote AI, support forms, or any other data transmission is added, update both the App Store privacy answers and privacy policy before uploading.

Privacy manifests are included in the app and keyboard extension. Both declare no tracking, no collected data, and App Group `UserDefaults` access using required-reason code `1C8F.1`.
