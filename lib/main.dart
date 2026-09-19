import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'utils/url_strategy.dart';
import 'views/home_screen.dart';
import 'views/privacy_policy_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Enable clean path URLs on web (e.g. /privacy); no-op elsewhere.
  configureUrlStrategy();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const TrackPeApp());
}

class TrackPeApp extends StatelessWidget {
  const TrackPeApp({super.key});

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case PrivacyPolicyScreen.routeName:
        return MaterialPageRoute(
          builder: (_) => const PrivacyPolicyScreen(),
          settings: settings,
        );
      case '/':
      default:
        // Unknown paths fall back to the home screen.
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: const RouteSettings(name: '/'),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, currentMode, _) {
        return MaterialApp(
          title: 'Track Pe',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,
          initialRoute: '/',
          onGenerateRoute: _onGenerateRoute,
          builder: (context, child) {
            final isDark = ThemeController.isDark(context);
            return Container(
              color: isDark ? const Color(0xFF07080A) : const Color(0xFFE2E8F0),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 480),
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: AppColors.bg(context),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(isDark ? 153 : 30),
                        blurRadius: 30,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: child ?? const SizedBox.shrink(),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
