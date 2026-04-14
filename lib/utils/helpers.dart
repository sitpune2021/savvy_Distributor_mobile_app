import 'package:flutter/material.dart';

class Helpers {
  // Show Snackbar
  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Simple Navigation
  static void navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  // Go Back
  static void goBack(BuildContext context) {
    Navigator.pop(context);
  }
}