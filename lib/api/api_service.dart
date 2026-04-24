import 'dart:convert';
import 'package:distributor/utils/app_logger.dart';
import 'package:distributor/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // 🔐 Get token
  Future<String?> _getToken() async {
    AppLogger.i("🔐 Getting token...");
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    AppLogger.d("Token: $token");
    return token;
  }

  // 🔥 COMMON REQUEST METHOD
  Future<dynamic> request({
    required String endpoint,
    String method = "GET",
    Map<String, dynamic>? body,
    bool isAuthRequired = false,
    Map<String, dynamic>? queryParams,
  }) async {
    AppLogger.i("🚀 API CALL START");
    AppLogger.d("Endpoint: $endpoint");
    AppLogger.d("Method: $method");

    // final url = Uri.parse(AppConstants.baseUrl + endpoint);
    // AppLogger.d("URL: $url");

    // ✅ Build URL with queryParams for GET requests
    final Uri url;
    if (method == "GET" && queryParams != null && queryParams.isNotEmpty) {
      url = Uri.parse(
        AppConstants.baseUrl + endpoint,
      ).replace(queryParameters: queryParams);
    } else {
      url = Uri.parse(AppConstants.baseUrl + endpoint);
    }

    AppLogger.d("URL: $url"); // Now logs: /orders?status=approved&page=1

    try {
      String? token;

      if (isAuthRequired) {
        token = await _getToken();
      }

      final headers = {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      };

      AppLogger.d("Headers: $headers");

      if (body != null) {
        AppLogger.d("Body: ${jsonEncode(body)}");
      }

      http.Response response;

      // 🔄 API CALL
      switch (method) {
        case "POST":
          response = await http.post(
            url,
            headers: headers,
            body: jsonEncode(body ?? {}),
          );
          break;

        case "PUT":
          response = await http.put(
            url,
            headers: headers,
            body: jsonEncode(body ?? {}),
          );
          break;

        case "DELETE":
          response = await http.delete(url, headers: headers);
          break;

        default:
          response = await http.get(url, headers: headers);
      }

      AppLogger.i("✅ Response Received");
      AppLogger.d("Status Code: ${response.statusCode}");
      AppLogger.d("Response: ${response.body}");

      final result = _handleResponse(response);

      AppLogger.i("🎉 API SUCCESS");
      return result;
    } catch (e) {
      AppLogger.e("❌ API ERROR: $e");
      rethrow;
    }
  }

  // 🔥 RESPONSE HANDLER
  dynamic _handleResponse(http.Response response) {
    final data = jsonDecode(response.body);

    switch (response.statusCode) {
      case 200:
      case 201:
        return data;

      case 400:
      case 401:
      case 422:
        // 🔥 Handle validation errors (multiple fields)
        if (data["errors"] != null) {
          final errors = data["errors"] as Map<String, dynamic>;

          final messages = errors.values
              .expand((e) => e as List)
              .map((e) => "• $e")
              .join("\n"); // ✅ combine all errors

          throw messages;
        }

        // fallback message
        throw data["message"] ?? "Something went wrong";

      case 404:
        throw data["message"] ?? "API Not Found";

      case 500:
        throw data["message"] ?? "Server error. Try again later";

      default:
        throw data["message"] ?? "Error (${response.statusCode})";
    }
  }
}
