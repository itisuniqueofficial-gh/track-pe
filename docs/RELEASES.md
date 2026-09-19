# Releases & Versioning

Track Pe uses a **GitHub-native, fully automated** release pipeline. GitHub is
the source of truth for versioning, tags, artifacts, and release history. You do
**not** build, sign, tag, or publish anything locally for production.

## Developer workflow

```
edit code → commit (conventional message) → push to main
```

GitHub Actions then runs CI, computes the next version, builds and signs the
Android artifacts, validates them, generates checksums and notes, and publishes
a GitHub Release with a new tag.

## Versioning policy

The version engine (`.github/scripts/compute_version.sh`) inspects
conventional-commit messages since the latest `v*.*.*` tag:

| Commit signal | Bump |
|---------------|------|
| `BREAKING CHANGE` in body, or `<type>!:` in subject | **major** |
| `feat:` | **minor** |
| `fix:` | **patch** |
| new commits but no clear signal (`auto`) | **patch** (deterministic fallback) |
| no new commits (`auto`) | **no release** |

- **versionName** = the computed semantic version (e.g. `1.2.3`).
- **versionCode** = `git rev-list --count HEAD` — a monotonically increasing,
  deterministic integer, so values never collide across releases.
- The version is injected at build time via
  `flutter build ... --build-name=<version> --build-number=<versionCode>`;
  `pubspec.yaml`'s `version:` is **not** edited per release.

## Triggers

- **Automatic:** push to `main` (documentation-only changes are ignored via
  `paths-ignore`). Add `[skip release]` to a commit message to opt out.
- **Manual:** the **Release** workflow's `workflow_dispatch` with a
  `release_type` of `auto`, `patch`, `minor`, or `major`. It uses the exact same
  build/sign/validate/publish steps.

## What the release workflow produces

```
TrackPe-vX.Y.Z-release.aab      # Google Play App Bundle (primary)
TrackPe-vX.Y.Z-arm64-v8a.apk
TrackPe-vX.Y.Z-armeabi-v7a.apk
TrackPe-vX.Y.Z-x86_64.apk
TrackPe-vX.Y.Z-universal.apk
SHA256SUMS
```

## Quality gates (release fails if any fail)

```
dependencies resolve → format → analyze → tests →
signed AAB → signed APKs → artifact validation
(package id, versionName, versionCode, signature) →
SHA256SUMS → GitHub Release
```

If any step fails, **no release is created** and no partial/broken release is
published.

## Idempotency & safety

- Serialized via `concurrency: track-pe-release` (`cancel-in-progress: false`).
- If a Release for the computed tag already exists, the workflow **skips**
  instead of overwriting it.
- The tag is created by the release action using `GITHUB_TOKEN`; token-driven
  pushes do not trigger further workflows, so there is **no release loop**.

## Signing

Handled entirely in CI from GitHub Secrets — see
[docs/ANDROID_SIGNING.md](ANDROID_SIGNING.md). Production releases **fail** if
signing secrets are missing (no debug fallback).
