import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../router/app_routes.dart';

class AuthService {
  // 🔥 Logout Function
  static Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.clear(); // ✅ clear all session

    // 🔥 Navigate to login & remove all screens
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    }
  }
}
