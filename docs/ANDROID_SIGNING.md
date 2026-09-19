# Android Signing

Production Android signing for Track Pe happens **entirely inside GitHub
Actions**. No keystore, password, or `key.properties` is ever committed.

## Secrets (names only — never store values in the repo)

Configure these as repository **Actions secrets**
(Settings → Secrets and variables → Actions):

| Secret | Purpose |
|--------|---------|
| `ANDROID_KEYSTORE_BASE64` | Base64-encoded release keystore (`.jks`) |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore (store) password |
| `ANDROID_KEY_PASSWORD` | Key password |
| `ANDROID_KEY_ALIAS` | Key alias |

## One-time keystore creation (maintainer, local, kept private)

```bash
keytool -genkey -v -keystore trackpe-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias trackpe

# Encode for the secret (single line, no wrapping):
base64 -w0 trackpe-release.jks > keystore.b64
```

Then paste the contents of `keystore.b64` into `ANDROID_KEYSTORE_BASE64`, and
set the password/alias secrets accordingly. Store the `.jks` somewhere safe
(e.g. a password manager). **Do not commit it.**

## How CI uses the secrets (`.github/workflows/release.yml`)

1. Verifies all four secrets are present — **fails the release if any is
   missing** (production never falls back to debug signing).
2. Decodes the keystore into `$RUNNER_TEMP` (outside the workspace).
3. Writes `android/key.properties` pointing at that temporary keystore.
4. Builds the signed AAB and APKs.
5. Validates each APK signature with `apksigner verify`.
6. Deletes `android/key.properties` and the temporary keystore (`if: always()`).

Secrets are never printed (`echo "$SECRET"` and equivalents are avoided) and the
keystore is never uploaded as an artifact.

## Local Gradle behaviour

`android/app/build.gradle.kts` reads `android/key.properties` when present. If it
is absent (typical local dev), the **release** build falls back to debug signing
so `flutter run --release` still works. This fallback is **development-only** —
CI always provides real signing and fails if it cannot.

`android/key.properties` and `*.jks`/`*.keystore` are git-ignored. See
`android/key.properties.example` for the expected keys.
