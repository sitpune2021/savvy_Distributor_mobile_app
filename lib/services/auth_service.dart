import 'package:distributor/api/api_endpoints.dart';
import 'package:distributor/api/api_service.dart';
import 'package:distributor/models/auth_login_model.dart';
import 'package:distributor/utils/app_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final ApiService _api = ApiService();

  // 🔐 CHECK LOGIN
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    AppLogger.d("Checking token: $token");

    return token != null && token.isNotEmpty;
  }

  // 🔐 LOGIN
  Future<DistributorModel> login(String email, String password) async {
    AppLogger.i("🔑 LOGIN START");

    try {
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

          // ✅ SAVE USER DATA
          await prefs.setString("name", model.data?.distributor?.name ?? "");
          await prefs.setString("email", model.data?.distributor?.email ?? "");

          AppLogger.i("💾 Token Saved");
        }

        return model;
      } else {
        AppLogger.w("Login Failed: ${model.message}");
        throw model.message;
      }
    } catch (e) {
      AppLogger.e("❌ LOGIN ERROR: $e");

      String message = e.toString();

      if (message.contains("SocketException")) {
        message = "No internet connection";
      }

      throw message.replaceAll("Exception: ", "");
    }
  }

  Future<dynamic> resetPassword(String email, String password) async {
    AppLogger.i("🔁 RESET PASSWORD START");

    try {
      final response = await _api.request(
        endpoint: ApiEndpoints.resetPassword,
        method: "POST",
        body: {"email": email, "password": password, "role": "distributor"},
      );

      AppLogger.d("Response: $response");

      if (response["status"] == true) {
        AppLogger.i("✅ Reset Success: ${response["message"]}");
        return response;
      } else {
        AppLogger.w("❌ Reset Failed: ${response["message"]}");
        throw response["message"]?.toString() ?? "Reset failed";
      }
    } catch (e) {
      AppLogger.e("❌ RESET ERROR: $e");

      String message = e.toString();

      if (message.contains("SocketException")) {
        message = "No internet connection";
      }

      throw message.replaceAll("Exception: ", "");
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
    await prefs.remove("token"); // ✅ safer than clear()
    await prefs.clear();

    AppLogger.i("🧹 Local data cleared");
    AppLogger.i("🎉 LOGOUT COMPLETE");
  }
}
