# CI/CD Architecture

Track Pe is GitHub-native: GitHub Actions is the only production build and
release environment. A developer only needs to `commit` and `push`.

## Workflows

```
.github/workflows/
├── ci.yml                 # every push/PR: format, analyze, test, web build, Android compile check
├── release.yml            # push to main / manual: version → sign → build → validate → GitHub Release
├── web-deploy.yml         # push to main / manual: build web (base-href "/") → GitHub Pages
└── dependency-review.yml  # PRs: flag risky dependency changes
.github/scripts/
└── compute_version.sh     # conventional-commit version engine
.github/dependabot.yml     # weekly updates for github-actions and pub
```

## Pipeline

```
Developer → git commit → push to main
        │
        ▼
   ci.yml (format · analyze · test · web · android compile)
        │
        ▼
   release.yml
     ├── verify signing secrets (fail if missing)
     ├── compute version (compute_version.sh)
     ├── idempotency check (skip if release exists)
     ├── quality gates (format · analyze · test)
     ├── decode keystore → key.properties
     ├── signed AAB + split APKs + universal APK
     ├── validate (package id · versionName · versionCode · signature)
     ├── SHA256SUMS
     ├── release notes (from git history)
     ├── GitHub Release (+ tag)
     └── cleanup signing material (always)
```

## Key design points

- **Flutter pinned** to `3.47.4` (stable) in every workflow for reproducibility.
- **Toolchain**: Temurin **Java 17**; the Android side uses the project's
  existing AGP `8.11.1` / Kotlin `2.2.20` / `compileSdk` from Flutter — unchanged.
- **Least privilege**: `ci.yml` and `dependency-review.yml` use
  `permissions: contents: read`; `release.yml` uses `contents: write`;
  `web-deploy.yml` uses `pages: write` + `id-token: write`. No `write-all`,
  no `pull_request_target`, no personal access tokens.
- **Secrets isolation**: signing secrets are used only by `release.yml`
  (push to `main` / manual dispatch), never by `pull_request` jobs.
- **No release loops**: the tag is created via `GITHUB_TOKEN`, which does not
  trigger further workflow runs; there is no tag-triggered workflow.
- **Concurrency**: `release.yml` uses `group: track-pe-release`,
  `cancel-in-progress: false`, so versions cannot be computed in parallel.
- **Docs-only changes** are ignored by `ci.yml` and `release.yml` via
  `paths-ignore`; `[skip release]` in a commit message also opts out.

## Caching

`subosito/flutter-action` is configured with `cache: true` to cache the Flutter
SDK/pub artifacts across runs.

## Supply-chain hardening (recommended follow-up)

Third-party actions are referenced by major-version tags for readability. For
stronger guarantees, pin them to immutable commit SHAs.

## Related docs

- [docs/RELEASES.md](RELEASES.md) — versioning policy & release outputs
- [docs/ANDROID_SIGNING.md](ANDROID_SIGNING.md) — signing secrets & flow
- [docs/CUSTOM_DOMAIN.md](CUSTOM_DOMAIN.md) — web custom domain / Pages
- [docs/CONFIGURATION.md](CONFIGURATION.md) — identity & configuration
