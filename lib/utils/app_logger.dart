import 'package:flutter/foundation.dart';

/// Minimal logging abstraction for Track Pe.
///
/// - Logs are emitted only in debug/profile builds; in release builds these
///   calls are no-ops so diagnostic detail never ships to end users.
/// - Callers must NOT pass sensitive data (full UPI URIs, VPAs, merchant
///   credentials, raw QR contents, secrets). Prefer logging non-sensitive
///   summaries (e.g. "upi launch failed", counts, error types).
class AppLogger {
  const AppLogger._();

  static void debug(String message) {
    if (kReleaseMode) return;
    debugPrint('[TrackPe] $message');
  }

  static void warn(String message) {
    if (kReleaseMode) return;
    debugPrint('[TrackPe][WARN] $message');
  }

  static void error(String message, [Object? error]) {
    if (kReleaseMode) return;
    debugPrint('[TrackPe][ERROR] $message${error != null ? ': $error' : ''}');
  }
}
