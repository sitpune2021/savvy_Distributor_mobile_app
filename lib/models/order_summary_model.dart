import 'dart:convert';

OrderSummaryModel orderSummaryModelFromJson(String str) =>
    OrderSummaryModel.fromJson(json.decode(str));

String orderSummaryModelToJson(OrderSummaryModel data) =>
    json.encode(data.toJson());

class OrderSummaryModel {
  final Orders orders;
  final PlantStock plantStock;

  OrderSummaryModel({required this.orders, required this.plantStock});

  factory OrderSummaryModel.fromJson(Map<String, dynamic>? json) {
    return OrderSummaryModel(
      orders: Orders.fromJson(json?["orders"]),
      plantStock: PlantStock.fromJson(json?["plant_stock"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "orders": orders.toJson(),
    "plant_stock": plantStock.toJson(),
  };
}

class Orders {
  final int total;
  final int pending;
  final int approved;
  final int inProduction;
  final int productionCompleted;
  final int dispatched;
  final int delivered;
  final int closed;
  final int rejected;

  Orders({
    required this.total,
    required this.pending,
    required this.approved,
    required this.inProduction,
    required this.productionCompleted,
    required this.dispatched,
    required this.delivered,
    required this.closed,
    required this.rejected,
  });

  factory Orders.fromJson(Map<String, dynamic>? json) {
    return Orders(
      total: _toInt(json?["total"]),
      pending: _toInt(json?["pending"]),
      approved: _toInt(json?["approved"]),
      inProduction: _toInt(json?["in_production"]),
      productionCompleted: _toInt(json?["production_completed"]),
      dispatched: _toInt(json?["dispatched"]),
      delivered: _toInt(json?["delivered"]),
      closed: _toInt(json?["closed"]),
      rejected: _toInt(json?["rejected"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "total": total,
    "pending": pending,
    "approved": approved,
    "in_production": inProduction,
    "production_completed": productionCompleted,
    "dispatched": dispatched,
    "delivered": delivered,
    "closed": closed,
    "rejected": rejected,
  };
}

class PlantStock {
  final int totalEmptyJars;
  final List<Plants> plants;

  PlantStock({required this.totalEmptyJars, required this.plants});

  factory PlantStock.fromJson(Map<String, dynamic>? json) {
    return PlantStock(
      totalEmptyJars: _toInt(json?["total_empty_jars"]),
      plants:
          (json?["plants"] as List?)?.map((e) => Plants.fromJson(e)).toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    "total_empty_jars": totalEmptyJars,
    "plants": plants.map((e) => e.toJson()).toList(),
  };
}

class Plants {
  final int plantId;
  final String plantName;
  final int remainingEmptyJars;

  Plants({
    required this.plantId,
    required this.plantName,
    required this.remainingEmptyJars,
  });

  factory Plants.fromJson(Map<String, dynamic>? json) {
    return Plants(
      plantId: _toInt(json?["plant_id"]),
      plantName: json?["plant_name"] ?? "",
      remainingEmptyJars: _toInt(json?["remaining_empty_jars"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "plant_id": plantId,
    "plant_name": plantName,
    "remaining_empty_jars": remainingEmptyJars,
  };
}

/// 🔹 Helper to safely convert dynamic to int
int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  return int.tryParse(value.toString()) ?? 0;
}
