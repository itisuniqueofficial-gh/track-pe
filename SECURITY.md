# Security Policy

## Supported versions

Track Pe is an educational/research application. Security fixes are applied to
the latest released version and the `main` branch.

| Version | Supported |
|---------|-----------|
| latest release | ✅ |
| older releases | ❌ |

## Reporting a vulnerability

Please report security issues **privately**, via either channel:

- **Email:** track-pe@itisuniqueofficial.com
- **GitHub Security Advisories:** open a draft advisory at
  <https://github.com/itisuniqueofficial-gh/track-pe/security/advisories/new>.

Do **not** open a public issue for security reports.

When reporting, include reproduction steps and impact. We aim to acknowledge
reports within a reasonable time and will coordinate a fix and disclosure.

### Please never include

- UPI IDs (VPAs), payment details, or transaction references
- Passwords, tokens, API keys, or signing credentials
- Keystores or `key.properties`

## Security limitations (by design)

- Track Pe does **not** process, settle, or verify payments; the actual
  transaction is performed by the user's external UPI app.
- MDR/GST figures are illustrative and are not authoritative regulatory data.
- The app is offline/client-side and has no backend, accounts, or stored
  credentials.
