// // import 'package:flutter/material.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import '../router/app_routes.dart';

// // class AuthService {
// //   // 🔥 Logout Function
// //   static Future<void> logout(BuildContext context) async {
// //     final prefs = await SharedPreferences.getInstance();

// //     await prefs.clear(); // ✅ clear all session

// //     // 🔥 Navigate to login & remove all screens
// //     if (context.mounted) {
// //       Navigator.pushNamedAndRemoveUntil(
// //         context,
// //         AppRoutes.login,
// //         (route) => false,
// //       );
// //     }
// //   }
// // }

// import 'package:distributor/api/api_endpoints.dart';
// import 'package:distributor/api/api_service.dart';
// import 'package:distributor/models/auth_login_model.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class AuthService {
//   final ApiService _api = ApiService();

//   // 🔐 Save token
//   Future<void> _saveToken(String token) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString("token", token);
//   }

//   // 🔥 LOGIN
//   Future<DistributorModel> login(String email, String password) async {
//     final response = await _api.request(
//       endpoint: ApiEndpoints.login,
//       method: "POST",
//       body: {
//         "email": email,
//         "password": password,
//         "role": "distributor",
//       },
//     );

//     final model = DistributorModel.fromJson(response);

//     if (model.status) {
//       final token = model.data?.token ?? "";

//       if (token.isNotEmpty) {
//         await _saveToken(token);
//       }

//       return model;
//     } else {
//       throw Exception(model.message);
//     }
//   }

//   // 🔓 LOGOUT
//   Future<void> logout() async {
//     await _api.request(
//       endpoint: ApiEndpoints.logout,
//       method: "POST",
//       isAuthRequired: true,
//     );

//     final prefs = await SharedPreferences.getInstance();
//     await prefs.clear();
//   }
// }
import 'package:distributor/api/api_endpoints.dart';
import 'package:distributor/api/api_service.dart';
import 'package:distributor/models/auth_login_model.dart';
import 'package:distributor/utils/app_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final ApiService _api = ApiService();

  // 🔐 LOGIN
  Future<DistributorModel> login(String email, String password) async {
    AppLogger.i("🔑 LOGIN START");

    final response = await _api.request(
      endpoint: ApiEndpoints.login,
      method: "POST",
      body: {"email": email, "password": password, "role": "distributor"},
    );

    final model = DistributorModel.fromJson(response);

    AppLogger.d("Status: ${model.status}");
    AppLogger.d("Message: ${model.message}");

    if (model.status) {
      final token = model.data?.token ?? "";

      AppLogger.i("🔐 Token: $token");

      if (token.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", token);
        AppLogger.i("💾 Token Saved");
      }

      return model;
    } else {
      AppLogger.w("Login Failed: ${model.message}");
      throw Exception(model.message);
    }
  }

  // 🔓 LOGOUT
  Future<void> logout() async {
    AppLogger.i("🚪 LOGOUT START");

    try {
      // 🔥 Call logout API (with token)
      await _api.request(
        endpoint: ApiEndpoints.logout,
        method: "POST",
        isAuthRequired: true, // 🔐 important
      );

      AppLogger.i("✅ Logout API Success");
    } catch (e) {
      // ⚠️ Even if API fails, still logout locally
      AppLogger.w("⚠️ Logout API failed: $e");
    }

    // 🧹 Always clear local data
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    AppLogger.i("🧹 Local data cleared");
    AppLogger.i("🎉 LOGOUT COMPLETE");
  }
}
