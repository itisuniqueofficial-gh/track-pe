import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../widgets/track_pe_logo.dart';

/// Privacy Policy page for Track Pe, reachable at `/privacy`.
///
/// Reuses the app's theme, colours, typography and NeoPOP surfaces so it reads
/// as a first-class Track Pe screen. Content reflects the app's actual
/// behaviour: no accounts, no backend, in-memory only, client-side UPI deep
/// links, local camera QR scanning, and no analytics.
class PrivacyPolicyScreen extends StatelessWidget {
  static const String routeName = '/privacy';

  const PrivacyPolicyScreen({super.key});

  static const String _supportEmail = 'track-pe@itisuniqueofficial.com';
  static const String _website = 'https://track-pe.itisuniqueofficial.com/';
  static const String _company = 'https://www.itisuniqueofficial.com/';
  static const String _developer = 'https://jaydatt.pages.dev/';

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // Silently ignore; the page remains usable if no handler is available.
    }
  }

  void _goBack(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Title widget updates the browser tab title on web.
    return Title(
      title: 'Privacy Policy — Track Pe',
      color: AppColors.primaryBlue,
      child: Scaffold(
        backgroundColor: AppColors.bg(context),
        appBar: AppBar(
          backgroundColor: AppColors.bg(context),
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: AppColors.text(context),
            ),
            tooltip: 'Back',
            onPressed: () => _goBack(context),
          ),
          title: const TrackPeLogo(size: 22, showBadge: false),
          actions: [
            ValueListenableBuilder<ThemeMode>(
              valueListenable: ThemeController.themeMode,
              builder: (context, mode, _) {
                final dark = mode == ThemeMode.dark;
                return IconButton(
                  onPressed: ThemeController.toggleTheme,
                  icon: Icon(
                    dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    color: dark
                        ? AppColors.goldenYellow
                        : AppColors.primaryBlueDark,
                    size: 22,
                  ),
                  tooltip: dark
                      ? 'Switch to Light Mode'
                      : 'Switch to Dark Mode',
                );
              },
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _title(context),
                const SizedBox(height: 6),
                Text(
                  'Last Updated: September 2026',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSub(context),
                  ),
                ),
                const SizedBox(height: 16),

                _section(context, 'Introduction', [
                  'Track Pe is an open-source, educational and research application '
                      'developed by It Is Unique Official and maintained by Jaydatt '
                      'Khodave. It demonstrates how a bill can be algorithmically '
                      'split into sub-₹2,000 UPI payment tranches and rendered as '
                      'standard UPI deep links / QR codes.',
                  'Track Pe is not a bank, payment gateway, payment processor, or UPI '
                      'payment service provider. It does not process, settle, or verify '
                      'payments. This policy explains how the application handles '
                      'information.',
                ]),

                _section(
                  context,
                  'Information We Collect',
                  [
                    'Track Pe has no user accounts and no backend server operated by '
                        'the app. Based on the current implementation:',
                  ],
                  bullets: [
                    'No account, sign-up, or login is required.',
                    'No password is requested or stored.',
                    'No bank account credentials, UPI PIN, or OTP are requested by Track Pe.',
                    'There is no backend user database operated by the application.',
                    'Amounts, merchant names, and UPI IDs you enter are processed on '
                        'your device to build UPI links and are held only in app memory.',
                  ],
                ),

                _section(context, 'How We Use Information', [
                  'Information you enter (such as a bill amount, merchant name, or '
                      'UPI ID) is used solely, on your device, to generate UPI payment '
                      'links / QR codes and to display split calculations. It is not '
                      'transmitted to a server operated by Track Pe.',
                ]),

                _section(context, 'UPI and Payment Information', [
                  'When you choose to pay, Track Pe may construct a standard '
                      'upi://pay link locally and hand it off to an external, '
                      'UPI-compatible application that you have installed. That '
                      'external application performs the actual transaction and is '
                      'governed by its own privacy policy and terms.',
                  'Track Pe does not have access to your UPI PIN, bank password, '
                      'OTP, account balance, or transaction authorization credentials. '
                      'Any "paid" state shown in the app is a local, simulated status '
                      'and is not proof that money was transferred.',
                ]),

                _section(context, 'Camera and QR Scanner', [
                  'With your permission, Track Pe may use your device camera to scan '
                      'UPI QR codes. Scanning and decoding happen locally on your '
                      'device. Track Pe does not upload camera images or scanned QR '
                      'contents to any server. You can decline or revoke the camera '
                      'permission in your device settings; manual entry remains '
                      'available.',
                ]),

                _section(context, 'Local Data and Storage', [
                  'Track Pe does not use a database or persistent storage for your '
                      'data. Information you enter exists only in application memory '
                      'during use and is discarded when the app is closed. The app '
                      'does not use SharedPreferences, Hive, SQLite, secure storage, '
                      'or browser local storage for personal data.',
                ]),

                _section(
                  context,
                  'Third-Party Applications and Services',
                  ['Track Pe interacts with the following where relevant:'],
                  bullets: [
                    'External UPI apps — opened via a UPI deep link when you initiate a payment.',
                    'Your operating system share sheet — when you choose to share text.',
                    'Google Fonts — the app may request font files from Google\'s servers to render its typography.',
                    'Hosting/CDN — the web version is served via GitHub Pages, which may keep standard server logs.',
                    'These third parties have their own privacy practices, which Track Pe does not control.',
                  ],
                ),

                _section(context, 'Analytics / Diagnostics', [
                  'Track Pe does not integrate any analytics, advertising, or crash/'
                      'diagnostic reporting SDKs (for example, no Google Analytics, '
                      'Firebase, Crashlytics, Sentry, or ad networks).',
                ]),

                _section(context, 'Data Security', [
                  'Because Track Pe operates on your device without an app-operated '
                      'backend or stored credentials, the attack surface for your data '
                      'is limited. No system can be guaranteed to be completely secure. '
                      'You should never share your UPI PIN, OTP, bank passwords, or '
                      'other authentication credentials with Track Pe or anyone else.',
                ]),

                _section(context, 'Data Retention', [
                  'Track Pe does not maintain a backend user database and does not '
                      'retain your entered information after the session ends. Data '
                      'held in memory is cleared when you close the application.',
                ]),

                _section(context, "Children's Privacy", [
                  'Track Pe does not intentionally collect personal information from '
                      'children through any user-account system, because it has no '
                      'accounts and no backend data collection.',
                ]),

                _section(context, 'External Links', [
                  'Track Pe may link to, or hand off to, external websites and '
                      'applications. Those services operate under their own privacy '
                      'policies and practices, which Track Pe does not control.',
                ]),

                _section(context, 'Changes to This Privacy Policy', [
                  'We may update this Privacy Policy when the application\'s '
                      'functionality, data practices, or legal requirements change. '
                      'The "Last Updated" date above reflects the latest revision.',
                ]),

                _contactSection(context),
                const SizedBox(height: 20),
                _footer(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _title(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(
        'Privacy Policy',
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
          color: AppColors.text(context),
        ),
      ),
    );
  }

  Widget _section(
    BuildContext context,
    String heading,
    List<String> paragraphs, {
    List<String> bullets = const [],
  }) {
    final textColor = AppColors.text(context);
    final subColor = AppColors.textSub(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              heading,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.2,
                color: textColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          for (final p in paragraphs) ...[
            Text(
              p,
              style: TextStyle(fontSize: 13.5, height: 1.6, color: subColor),
            ),
            const SizedBox(height: 8),
          ],
          for (final b in bullets)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 7, right: 8),
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryBlue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      b,
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.55,
                        color: subColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _contactSection(BuildContext context) {
    final subColor = AppColors.textSub(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            'Contact',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.text(context),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'For questions about this Privacy Policy, contact It Is Unique Official:',
          style: TextStyle(fontSize: 13.5, height: 1.6, color: subColor),
        ),
        const SizedBox(height: 10),
        _linkRow(
          context,
          Icons.mail_outline_rounded,
          _supportEmail,
          () => _open('mailto:$_supportEmail'),
        ),
        _linkRow(
          context,
          Icons.public_rounded,
          'track-pe.itisuniqueofficial.com',
          () => _open(_website),
        ),
        _linkRow(
          context,
          Icons.business_rounded,
          'It Is Unique Official',
          () => _open(_company),
        ),
        _linkRow(
          context,
          Icons.code_rounded,
          'Developed by Jaydatt Khodave',
          () => _open(_developer),
        ),
      ],
    );
  }

  Widget _linkRow(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primaryBlue),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBlue,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _footer(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border(context))),
      ),
      child: Text(
        'Track Pe · © 2026 It Is Unique Official · Developed by Jaydatt Khodave\n'
        'Educational / research application. Track Pe does not process or settle payments.',
        style: TextStyle(
          fontSize: 11,
          height: 1.5,
          color: AppColors.textSub(context),
        ),
      ),
    );
  }
}
