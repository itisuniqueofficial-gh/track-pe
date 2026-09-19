// Selects the correct URL strategy implementation per platform.
// On web this enables clean path URLs (e.g. /privacy); on other platforms it is
// a no-op. Conditional import so non-web builds never depend on
// flutter_web_plugins.
export 'url_strategy_stub.dart' if (dart.library.html) 'url_strategy_web.dart';
