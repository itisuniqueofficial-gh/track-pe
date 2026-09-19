# Changelog

All notable changes to Track Pe are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- Rebranded the project from SplitPe to **Track Pe** across the app, platform
  metadata, and documentation.
- Set production package identifiers to `com.itisuniqueofficial.trackpe`
  (Android/iOS/macOS) and the Dart package name to `track_pe`.
- Refactored money handling to **integer paise** internally (`SplitOrder`,
  `Tranche`, `SplitEngine`), guaranteeing tranche amounts sum exactly to the
  total; decimal formatting now happens only at presentation boundaries.
- Centralized illustrative MDR/GST logic into a single `MdrPolicy` service.
- Strengthened in-app disclaimers to make the educational, non-settlement
  nature of the app explicit.

### Added
- Continuous integration (format, analyze, test, web build, Android compile
  validation) via GitHub Actions.
- **Automated, GitHub-native release pipeline**: pushes to `main` compute the
  next semantic version from conventional commits (`.github/scripts/compute_version.sh`),
  build a signed AAB + split-per-ABI APKs + universal APK, validate package
  id/versionName/versionCode/signature, generate `SHA256SUMS` and release notes,
  and publish a GitHub Release + tag. Idempotent, serialized, loop-safe, with a
  `workflow_dispatch` manual trigger (auto/patch/minor/major). No local build,
  signing, tagging, or version editing is required.
- Web deploy, dependency-review, and Dependabot workflows.
- Repository docs: `SECURITY.md`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`,
  `SUPPORT.md`, `docs/RELEASE.md`, `docs/CONFIGURATION.md`, issue/PR templates.
- Web custom-domain configuration: `web/CNAME` (`track-pe.itisuniqueofficial.com`)
  and root `--base-href "/"` for the production Pages deployment.
- Expanded tests for the split engine, money utility, MDR policy, order status
  transitions, and app smoke tests.

### Note
- **License is pending an owner decision.** The project is intended to be full
  open source (2026); the specific license has not yet been finalized and no
  `LICENSE` file is committed.

### Security
- Hardened `.gitignore` to exclude keystores, `key.properties`, and `.env` files.
- Added a lightweight logging abstraction that suppresses logs in release builds
  and avoids logging full UPI URIs or sensitive QR contents.
