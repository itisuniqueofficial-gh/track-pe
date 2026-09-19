import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_logger.dart';

class UpiService {
  /// Launches a UPI intent URI (opens Google Pay, PhonePe, Paytm, etc.).
  ///
  /// Returns `false` when no handler is available or launching fails. The URI
  /// itself is never logged, since it can contain merchant/payment details.
  static Future<bool> launchUpiIntent(String upiUri) async {
    final uri = Uri.tryParse(upiUri);
    if (uri == null || uri.scheme.toLowerCase() != 'upi') {
      AppLogger.warn('Refusing to launch non-UPI or malformed URI.');
      return false;
    }
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalNonBrowserApplication,
      );
      if (launched) return true;

      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      AppLogger.error('UPI intent launch failed', e.runtimeType);
      try {
        return await launchUrl(uri);
      } catch (e2) {
        AppLogger.error('UPI intent fallback launch failed', e2.runtimeType);
        return false;
      }
    }
  }

  /// Copies text (e.g. a VPA or link) to the clipboard.
  static Future<bool> copyToClipboard(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      return true;
    } catch (e) {
      AppLogger.error('Clipboard copy failed', e.runtimeType);
      return false;
    }
  }

  /// Generates a shareable text for social media.
  static String generateViralShareText({
    required double totalAmount,
    required double mdrSaved,
    required int trancheCount,
  }) {
    return '⚡ Illustrative saving of ₹${mdrSaved.toStringAsFixed(2)} on a '
        '₹${totalAmount.toStringAsFixed(0)} bill using Track Pe!\n\n'
        'Split into $trancheCount sub-₹2,000 tranches. Educational demo only — '
        'your UPI app performs the actual payment. 🚀\n'
        '#UPI #Fintech #TrackPe';
  }

  /// Generates a group payment message for sharing.
  static String generateGroupShareMessage({
    required String merchantName,
    required String payerName,
    required double amount,
    required String upiUri,
  }) {
    return 'Hey $payerName, your share for $merchantName is '
        '₹${amount.toStringAsFixed(2)}.\n'
        'Pay via your UPI app: $upiUri';
  }
}
