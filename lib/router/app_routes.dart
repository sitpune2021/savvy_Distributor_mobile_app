import 'package:distributor/screens/home_screen.dart';
import 'package:distributor/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/reset_password_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String resetPassword = '/reset-password';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case login:
        return MaterialPageRoute(builder: (_) => LoginScreen());

      case dashboard:
        return MaterialPageRoute(builder: (_) => HomeScreen());

      case resetPassword:
        return MaterialPageRoute(builder: (_) => ResetPasswordScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(body: Center(child: Text("No route found"))),
        );
    }
  }
}
