import 'package:distributor/screens/home_screen.dart';
import 'package:distributor/screens/order_list_screen.dart';
import 'package:distributor/screens/order_request_screen.dart';
import 'package:distributor/screens/orders_screen.dart';
import 'package:distributor/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/reset_password_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String resetPassword = '/reset-password';
  static const String orderRequest = '/order-request';
  static const String orderList = 'order-list';
  static const String ordersList = 'orders-list';

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

      case orderRequest:
        return MaterialPageRoute(builder: (_) => const OrderRequestScreen());

      case orderList:
        final int initialTab = settings.arguments as int? ?? 0;

        return MaterialPageRoute(
          builder: (_) => OrderListScreen(initialTab: initialTab),
        );

      case ordersList:
        return MaterialPageRoute(builder: (_) => OrdersListScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(body: Center(child: Text("No route found"))),
        );
    }
  }
}
