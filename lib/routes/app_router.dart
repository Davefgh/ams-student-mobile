import 'package:flutter/material.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/dashboard/dashboard_screen.dart';
import '../presentation/screens/profile/profile_screen.dart';
import '../presentation/screens/scanner/scanner_screen.dart';

class AppRouter {
  // Route names
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';
  static const String scanner = '/scanner';

  // Generate routes
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );

      case dashboard:
        return MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
          settings: settings,
        );

      case profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
          settings: settings,
        );

      case scanner:
        return MaterialPageRoute(
          builder: (_) => const ScannerScreen(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text(
                'No route defined for ${settings.name}',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        );
    }
  }

  // Helper method for named navigation
  static Future<dynamic> navigateTo(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  // Helper method for replacement navigation
  static Future<dynamic> navigateAndReplace(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }

  // Helper method to pop and push
  static Future<dynamic> navigateAndRemoveUntil(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }
}