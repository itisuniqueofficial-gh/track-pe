<div align="center">

# ⚡ Track Pe

**An open-source Flutter project by It Is Unique Official.**

An educational Flutter app that demonstrates algorithmic sub-₹2,000 UPI bill tranching.

[![CI](https://github.com/itisuniqueofficial-gh/track-pe/actions/workflows/ci.yml/badge.svg)](https://github.com/itisuniqueofficial-gh/track-pe/actions/workflows/ci.yml)
[![Release](https://github.com/itisuniqueofficial-gh/track-pe/actions/workflows/release.yml/badge.svg)](https://github.com/itisuniqueofficial-gh/track-pe/actions/workflows/release.yml)
[![Flutter](https://img.shields.io/badge/Flutter-3.47.4-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.13-0175C2?logo=dart&logoColor=white)](https://dart.dev)

</div>

---

> [!IMPORTANT]
> **Educational / research use only.** Track Pe does **not** process, settle, or verify UPI
> payments — your UPI app performs any actual transaction. All MDR/GST figures shown are
> **illustrative assumptions**, not current official NPCI/RBI/CBIC policy. Always verify current
> rules with authoritative sources.

## Links

| Resource | URL |
|----------|-----|
| Website | https://track-pe.itisuniqueofficial.com/ |
| Repository | https://github.com/itisuniqueofficial-gh/track-pe |
| Discussions | https://github.com/itisuniqueofficial-gh/track-pe/discussions |
| Issues | https://github.com/itisuniqueofficial-gh/track-pe/issues |
| Support | track-pe@itisuniqueofficial.com |
| Company | It Is Unique Official — https://www.itisuniqueofficial.com/ |
| Developer | Jaydatt Khodave — https://jaydatt.pages.dev/ |

## What it is

Under Indian digital-payment rules, single UPI merchant transactions above **₹2,000** may attract
MDR/interchange fees (plus GST on the fee), while transactions at/under ₹2,000 are generally
exempt. Track Pe illustrates how a larger bill can be algorithmically split into compliant
sub-₹2,000 tranches, each rendered as a standard `upi://pay` intent/QR. It is a client-side,
offline-capable demonstration with no backend.

## Features

- **Tranching engine** — splits a bill into ≤ ₹1,999 tranches using integer-paise arithmetic that
  guarantees the parts sum exactly to the total and never exceed the cap.
- **POS checkout** — enter/scan a bill, pick a merchant handle, generate the tranche set.
- **Group split** — divide a bill across 2–8 people with exact remainder handling.
- **MDR "Roast" calculator** — illustrative annual MDR + GST estimator.
- **QR scanner** — camera scanning with torch, camera switch and manual paste entry.
- **UPI validator** — NPCI-style VPA regex, 50+ PSP/bank handle registry, XSS sanitization,
  amount bounds, and rejection of non-UPI/dangerous URI schemes.
- **NeoPOP UI** with light/dark themes.

## Architecture

```text
lib/
├── models/     # SplitOrder, Tranche (integer-paise source of truth)
├── services/   # split_engine, upi_validator, upi_service, mdr_policy
├── views/      # POS, group split, savings calculator, QR scanner, home
├── widgets/    # NeoPOP components, tranche cards, modals, logo
├── theme/      # colors, themes, ThemeController
├── utils/      # money (paise helpers), app_logger
└── main.dart
```

Money is handled internally as **integer paise** (`₹1 = 100 paise`); conversion to decimal happens
only at presentation boundaries. Illustrative MDR/GST logic lives in a single `MdrPolicy` service.

## Supported platforms

Android, iOS, Web, Linux, macOS, Windows (Flutter multi-platform).

## Getting started

Prerequisites: Flutter `3.47.4` (stable), Dart `3.13.x`.

```bash
flutter pub get
flutter run
```

## Development

```bash
dart format .                                   # format
flutter analyze                                 # static analysis
flutter test                                    # unit + widget tests
flutter build web --release --base-href "/"     # production web build (root domain)
```

## Testing

Unit and widget tests cover the split engine (boundaries, exact-sum, cap), the money utility, the
MDR policy, order status transitions, and the UPI validator. Run `flutter test`.

## Release process

Releases are **fully automated** and GitHub-native — no local builds, signing, or
tagging are required. Pushing to `main` runs CI, computes the next version from
conventional commits, builds and signs the Android artifacts, validates them,
generates `SHA256SUMS` and release notes, and publishes a GitHub Release. A
manual `workflow_dispatch` (auto/patch/minor/major) uses the same pipeline. See
[docs/RELEASES.md](docs/RELEASES.md), [docs/CI_CD.md](docs/CI_CD.md), and
[docs/ANDROID_SIGNING.md](docs/ANDROID_SIGNING.md).

## Downloads

Android artifacts are attached to each [GitHub Release](https://github.com/itisuniqueofficial-gh/track-pe/releases):
`TrackPe-vX.Y.Z-release.aab`, `TrackPe-vX.Y.Z-arm64-v8a.apk`,
`TrackPe-vX.Y.Z-armeabi-v7a.apk`, `TrackPe-vX.Y.Z-x86_64.apk`,
`TrackPe-vX.Y.Z-universal.apk`, and `SHA256SUMS`.

## Support

- **Questions / ideas / community:** [GitHub Discussions](https://github.com/itisuniqueofficial-gh/track-pe/discussions)
- **Bugs:** [GitHub Issues](https://github.com/itisuniqueofficial-gh/track-pe/issues)
- **Private / security:** track-pe@itisuniqueofficial.com — see [SECURITY.md](SECURITY.md)

Never include UPI IDs, payment details, or secrets in issues.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) and the [Code of Conduct](CODE_OF_CONDUCT.md).

## License

Track Pe is intended to be released as **full open source (2026)** by It Is Unique Official.

> [!NOTE]
> **License pending owner decision.** The original repository shipped without a `LICENSE`
> file, and the specific open-source license has not yet been finalized. Until a license is
> added by the owner, all rights are reserved by default. Choosing and committing the
> open-source license is a required owner action (see the project maintainers).

## Attribution

```text
Track Pe
© 2026 It Is Unique Official
Developed by Jaydatt Khodave
```

Maintained by **It Is Unique Official** (https://www.itisuniqueofficial.com/).
Developed by **Jaydatt Khodave** (https://jaydatt.pages.dev/).
