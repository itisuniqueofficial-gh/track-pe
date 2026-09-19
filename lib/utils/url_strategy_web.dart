import 'package:flutter_web_plugins/url_strategy.dart';

/// Enables clean path-based URLs on web (e.g. /privacy instead of /#/privacy).
void configureUrlStrategy() => usePathUrlStrategy();
