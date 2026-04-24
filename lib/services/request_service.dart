import 'package:distributor/api/api_service.dart';
import 'package:distributor/models/order_list_model.dart';
import 'package:distributor/models/order_summary_model.dart';
import 'package:distributor/models/orders_list_model.dart';
import 'package:distributor/models/plant_model.dart';
import 'package:distributor/models/varient_model.dart';
import 'package:distributor/utils/app_logger.dart';
import 'package:distributor/api/api_endpoints.dart';

class RequestService {
  final ApiService _api = ApiService();

  ///
  Future<OrderSummaryModel> getOrderSummary() async {
    AppLogger.i("📊 FETCH ORDER SUMMARY START");

    try {
      final response = await _api.request(
        endpoint: ApiEndpoints.orderSummary,
        method: "GET",
        isAuthRequired: true,
      );

      final model = OrderSummaryModel.fromJson(response);

      AppLogger.d("Orders Total: ${model.orders.total}");
      AppLogger.d("Plants Count: ${model.plantStock.plants.length}");

      AppLogger.i("✅ Order Summary fetched");

      return model;
    } catch (e) {
      AppLogger.e("❌ ORDER SUMMARY ERROR: $e");

      String message = e.toString();

      if (message.contains("SocketException")) {
        message = "No internet connection";
      }

      throw message.replaceAll("Exception: ", "");
    }
  }

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
    required int deliveredJars,
    // int? usedPreviousStock, // ✅ optional

    required int requiredLabeledJars,
    required int requiredUnlabeledJars,
    required Map<String, dynamic> jarsWithLabel, // ✅ {"variantId": qty}
    required bool allowRemainingStock,
  }) async {
    AppLogger.i("🚀 SUBMIT ORDER START");

    try {
      /// ✅ ALWAYS SEND LIST (NEVER NULL)

      final body = <String, dynamic>{
        "plant_id": plantId,
        "delivered_jars": deliveredJars,
        // if (usedPreviousStock != null)
        //   "used_previous_stock": usedPreviousStock, // ✅ only if checkbox on
        "required_labeled_jars": requiredLabeledJars,
        "required_unlabeled_jars": requiredUnlabeledJars,
        "jars_with_label": jarsWithLabel, // ✅ {"10": 20}
        "allow_remaining_stock": allowRemainingStock,
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

  /// 📦 GET ORDERS LIST (WITH FILTER + PAGINATION)
  Future<OrderData> getOrders({String? status, int page = 1}) async {
    AppLogger.i("📦 FETCH ORDERS START");

    try {
      final queryParams = <String, String>{
        // "page": page.toString(),
        // if (status != null && status.isNotEmpty) "status": status.toLowerCase(),
        if (status != null && status.isNotEmpty) "status": status.toLowerCase(),
        "page": page.toString(),
      };

      AppLogger.d("🔗 Endpoint: ${ApiEndpoints.ordersList}");
      AppLogger.d("QueryParams: $queryParams");

      final response = await _api.request(
        endpoint: ApiEndpoints.ordersList,
        method: "GET",
        isAuthRequired: true,
        queryParams: queryParams,
      );

      // ✅ Null-safety check before parsing
      if (response == null) {
        throw Exception("Empty response from server");
      }

      final model = OrdersListModel.fromJson(response);

      AppLogger.d("Orders Count: ${model.data.orders.length}");
      AppLogger.d("Current Page: ${model.data.currentPage}");
      AppLogger.d("Last Page: ${model.data.lastPage}");
      AppLogger.d("✅ Status Filter: ${status ?? 'ALL'}");
      AppLogger.i("✅ Orders fetched successfully");

      return model.data;
    } catch (e) {
      AppLogger.e("❌ ORDERS FETCH ERROR: $e");

      String message = e.toString();

      if (message.contains("SocketException")) {
        message = "No internet connection";
      }

      throw message.replaceAll("Exception: ", "");
    }
  }
}
