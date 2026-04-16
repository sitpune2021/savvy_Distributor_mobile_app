import 'package:distributor/api/api_service.dart';
import 'package:distributor/models/order_list_model.dart';
import 'package:distributor/models/plant_model.dart';
import 'package:distributor/models/varient_model.dart';
import 'package:distributor/utils/app_logger.dart';
import 'package:distributor/api/api_endpoints.dart';

class RequestService {
  final ApiService _api = ApiService();

  /// 🌱 GET PLANTS
  Future<List<Plant>> getPlants() async {
    AppLogger.i("🌱 FETCH PLANTS START");

    try {
      final response = await _api.request(
        endpoint: ApiEndpoints.plant,
        method: "GET",
        isAuthRequired: true,
      );

      final model = PlantModel.fromJson(response);

      AppLogger.d("Status: ${model.status}");

      if (model.status) {
        AppLogger.i("✅ Plants fetched: ${model.data.length}");
        return model.data;
      } else {
        throw "Failed to load plants";
      }
    } catch (e) {
      AppLogger.e("❌ PLANT FETCH ERROR: $e");

      String message = e.toString();

      if (message.contains("SocketException")) {
        message = "No internet connection";
      }

      throw message.replaceAll("Exception: ", "");
    }
  }

  /// 🧪 GET VARIANTS
  Future<List<VariantData>> getVariants() async {
    AppLogger.i("🧪 FETCH VARIANTS START");

    try {
      final response = await _api.request(
        endpoint: ApiEndpoints.labels,
        method: "GET",
        isAuthRequired: true,
      );

      final model = VariantModel.fromJson(response);

      AppLogger.d("Status: ${model.status}");
      AppLogger.d("Message: ${model.message}");

      if (model.status) {
        AppLogger.i("✅ Variants fetched: ${model.data.length}");
        return model.data;
      } else {
        AppLogger.w("❌ Variant Fetch Failed: ${model.message}");
        throw model.message;
      }
    } catch (e) {
      AppLogger.e("❌ VARIANT FETCH ERROR: $e");

      String message = e.toString();

      if (message.contains("SocketException")) {
        message = "No internet connection";
      }

      throw message.replaceAll("Exception: ", "");
    }
  }

  /// 🚀 SUBMIT ORDER
  Future<dynamic> submitOrder({
    required int plantId,
    required int requiredQuantity,
    required List<Map<String, dynamic>> labelBreakdown,
    required int unlabelCount,
    required bool keepAtPlant,
  }) async {
    AppLogger.i("🚀 SUBMIT ORDER START");

    try {
      /// ✅ ALWAYS SEND LIST (NEVER NULL)
      final List<Map<String, dynamic>> safeLabelBreakdown =
          labelBreakdown.isNotEmpty ? labelBreakdown : [];

      final body = {
        "plant_id": plantId,
        "required_quantity": requiredQuantity,
        "label_breakdown": safeLabelBreakdown,
        "unlabel_count": unlabelCount,
        "keep_at_plant": keepAtPlant,
      };

      AppLogger.d("📦 REQUEST BODY: $body");

      final response = await _api.request(
        endpoint: ApiEndpoints.orderRequest,
        method: "POST",
        isAuthRequired: true,
        body: body,
      );

      AppLogger.i("✅ ORDER SUBMITTED SUCCESSFULLY");

      return response;
    } catch (e) {
      AppLogger.e("❌ SUBMIT ORDER ERROR: $e");

      String message = e.toString();

      if (message.contains("SocketException")) {
        message = "No internet connection";
      }

      throw message.replaceAll("Exception: ", "");
    }
  }

  /// 📦 GET PENDING ORDERS ✅ ADD THIS
  Future<List<PendingOrder>> getPendingOrders() async {
    AppLogger.i("📦 FETCH PENDING ORDERS START");

    try {
      final response = await _api.request(
        endpoint: ApiEndpoints.pendingOrder,
        method: "GET",
        isAuthRequired: true,
      );

      final model = PendingOrderModel.fromJson(response);

      AppLogger.d("Status: ${model.success}");

      if (model.success) {
        AppLogger.i("✅ Orders fetched: ${model.orders.length}");
        return model.orders;
      } else {
        throw "Failed to load orders";
      }
    } catch (e) {
      AppLogger.e("❌ PENDING ORDER FETCH ERROR: $e");

      String message = e.toString();

      if (message.contains("SocketException")) {
        message = "No internet connection";
      }

      throw message.replaceAll("Exception: ", "");
    }
  }
}
