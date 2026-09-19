# Configuration

Track Pe is a client-side, offline-capable app with **no backend and no runtime
secrets**. It requires no environment configuration to build or run.

## Application identity

| Setting | Value |
|---------|-------|
| Display name | Track Pe |
| Dart package | `track_pe` |
| Android applicationId / namespace | `com.itisuniqueofficial.trackpe` |
| iOS / macOS bundle identifier | `com.itisuniqueofficial.trackpe` |
| Version (source of truth) | `pubspec.yaml` → `version:` |
| Production website | https://track-pe.itisuniqueofficial.com/ |
| Repository | https://github.com/itisuniqueofficial-gh/track-pe |
| Discussions | https://github.com/itisuniqueofficial-gh/track-pe/discussions |
| Support | track-pe@itisuniqueofficial.com |
| Company | It Is Unique Official — https://www.itisuniqueofficial.com/ |
| Developer | Jaydatt Khodave — https://jaydatt.pages.dev/ |

## Web base href

The production site is served from the **root** of the custom domain, so build
with:

```bash
flutter build web --release --base-href "/"
```

Do not use `/track-pe/` or `/SplitPe/` for the custom-domain deployment. See
[docs/CUSTOM_DOMAIN.md](CUSTOM_DOMAIN.md).

## Build-time configuration

The app does not require build-time environment variables. If you introduce
public, non-secret compile-time values later, pass them via Dart defines:

```bash
flutter run --dart-define=APP_ENV=dev
```

> ⚠️ **Never put secrets in Flutter configuration.** On Flutter Web, values
> embedded at build time are publicly inspectable in the shipped bundle.

## CI / release secrets

Signing secrets are used **only** by the tag-triggered release workflow and are
stored as GitHub Actions secrets (never committed, never printed). See
[docs/RELEASE.md](RELEASE.md):

- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_PASSWORD`
- `ANDROID_KEY_ALIAS`

## Local Android signing

For local release builds, copy `android/key.properties.example` to
`android/key.properties` (git-ignored) and fill in your values. When
`key.properties` is absent, release builds fall back to debug signing so
`flutter run --release` still works.

## Environment files

No `.env` files are required. If one is ever added, only place non-sensitive
public values in it, provide a committed `.env.example`, and keep real `.env*`
files git-ignored (already configured in `.gitignore`).
