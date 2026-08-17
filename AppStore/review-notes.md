# App Review Notes

TILOQ is an iPhone companion app plus a custom keyboard extension. It has no account, subscription, ads, analytics, or network service.

## Test the keyboard

1. Open TILOQ and use the Setup tab.
2. Open iOS Settings > General > Keyboard > Keyboards > Add New Keyboard.
3. Select TILOQ, then open Messages or Notes.
4. Hold the globe key and select TILOQ.
5. Type normally, or select existing text and tap Rewrite, Grammar, or Improve.
6. Review the local result and tap Insert.

The keyboard includes a globe key and remains functional without Full Access. `RequestsOpenAccess` is set to `false`.

## Apple Intelligence

Writing actions use Apple's on-device Foundation Models framework. They require an Apple Intelligence-compatible device with Apple Intelligence enabled and the model ready. If unavailable, TILOQ displays the device/model status and leaves selected text unchanged. Normal typing and encryption continue to work.

## Encryption test

1. In TILOQ > Settings, enable Encryption and enter any key text.
2. In another app, select text and tap Encrypt in the TILOQ keyboard.
3. Tap Insert to replace the selected text with a `TILOQ1.` message.
4. In TILOQ > Decrypt, paste that message and enter the same key text.

Encryption uses CryptoKit AES-GCM. The key text and keyboard preferences are stored locally in the shared App Group container so the companion app and keyboard can use them. TILOQ has no recovery service.

## Privacy

Writing is not sent to a TILOQ server. The app contains no networking or third-party SDKs. Clipboard access occurs only after the user taps Copy or Paste.
