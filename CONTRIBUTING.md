# Contributing to Track Pe

Thanks for your interest in improving Track Pe!

## Prerequisites

- Flutter `3.47.4` (stable), Dart `3.13.x`

## Workflow

1. **Fork** the repository and create a feature branch:
   ```bash
   git checkout -b feat/short-description
   ```
2. **Install** dependencies:
   ```bash
   flutter pub get
   ```
3. **Run** the app:
   ```bash
   flutter run
   ```
4. Make your change, then **verify** locally (these mirror CI):
   ```bash
   dart format .
   flutter analyze
   flutter test
   ```
5. **Commit** using Conventional Commits (see below), push, and open a **Pull
   Request** against `main`. Fill in the PR template checklist.

## Conventional Commits

Use these prefixes so release notes can be generated meaningfully:

```
feat:      a new feature
fix:       a bug fix
docs:      documentation only
refactor:  code change that neither fixes a bug nor adds a feature
perf:      performance improvement
test:      adding or fixing tests
build:     build system or dependencies
ci:        CI configuration
chore:     maintenance
security:  security-related change
```

## Guidelines

- Keep money math in **integer paise**; format to decimals only at the UI.
- Do not weaken the educational disclaimers or claim real payment settlement.
- Never commit secrets, keystores, or `key.properties`.
- Add or update tests for business-critical logic.

By contributing, you agree that your contributions will be licensed under the
project's eventual open-source license (see the License note in the
[README](README.md); the specific license is pending an owner decision).

## Community

- Questions, ideas, and discussion: [GitHub Discussions](https://github.com/itisuniqueofficial-gh/track-pe/discussions)
- Bugs: [GitHub Issues](https://github.com/itisuniqueofficial-gh/track-pe/issues)
- Private / security: track-pe@itisuniqueofficial.com (see [SECURITY.md](SECURITY.md))
