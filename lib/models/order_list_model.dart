import 'dart:convert';

PendingOrderModel pendingOrderModelFromJson(String str) =>
    PendingOrderModel.fromJson(json.decode(str));

String pendingOrderModelToJson(PendingOrderModel data) =>
    json.encode(data.toJson());

class PendingOrderModel {
  final bool success;
  final List<PendingOrder> orders;

  PendingOrderModel({required this.success, required this.orders});

  factory PendingOrderModel.fromJson(Map<String, dynamic> json) {
    return PendingOrderModel(
      success: json["success"] ?? false,
      orders: (json["data"] as List? ?? [])
          .map((x) => PendingOrder.fromJson(x))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": orders.map((x) => x.toJson()).toList(),
  };
}

class PendingOrder {
  final int id;
  final int plantId;
  final int distributorId;
  final int requiredQuantity;
  final List<LabelBreakdown> labelBreakdown;
  final String status;
  final String step;
  final bool keepAtPlant;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Plants? plant;

  PendingOrder({
    required this.id,
    required this.plantId,
    required this.distributorId,
    required this.requiredQuantity,
    required this.labelBreakdown,
    required this.status,
    required this.step,
    required this.keepAtPlant,
    this.createdAt,
    this.updatedAt,
    this.plant,
  });

  factory PendingOrder.fromJson(Map<String, dynamic> json) {
    return PendingOrder(
      id: json["id"] ?? 0,
      plantId: json["plant_id"] ?? 0,
      distributorId: json["distributor_id"] ?? 0,
      requiredQuantity: json["required_quantity"] ?? 0,
      labelBreakdown: (json["label_breakdown"] as List? ?? [])
          .map((x) => LabelBreakdown.fromJson(x))
          .toList(),
      status: json["status"] ?? "",
      step: json["step"] ?? "",
      keepAtPlant: json["keep_at_plant"] ?? false,
      createdAt: json["created_at"] != null
          ? DateTime.tryParse(json["created_at"])
          : null,
      updatedAt: json["updated_at"] != null
          ? DateTime.tryParse(json["updated_at"])
          : null,
      plant: json["plant"] != null ? Plants.fromJson(json["plant"]) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "plant_id": plantId,
    "distributor_id": distributorId,
    "required_quantity": requiredQuantity,
    "label_breakdown": labelBreakdown.map((x) => x.toJson()).toList(),
    "status": status,
    "step": step,
    "keep_at_plant": keepAtPlant,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "plant": plant?.toJson(),
  };
}

class LabelBreakdown {
  final int rawMaterialVariantId;
  final int quantity;

  LabelBreakdown({required this.rawMaterialVariantId, required this.quantity});

  factory LabelBreakdown.fromJson(Map<String, dynamic> json) {
    return LabelBreakdown(
      rawMaterialVariantId: json["raw_material_variant_id"] ?? 0,
      quantity: json["quantity"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    "raw_material_variant_id": rawMaterialVariantId,
    "quantity": quantity,
  };
}

class Plants {
  final int id;
  final String name;
  final String address;
  final String manager;
  final int managerId;
  final String location;
  final String pincode;
  final String details;
  final dynamic deletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final dynamic vendorId;

  Plants({
    required this.id,
    required this.name,
    required this.address,
    required this.manager,
    required this.managerId,
    required this.location,
    required this.pincode,
    required this.details,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    this.vendorId,
  });

  factory Plants.fromJson(Map<String, dynamic> json) {
    return Plants(
      id: json["id"] ?? 0,
      name: json["name"] ?? "",
      address: json["address"] ?? "",
      manager: json["manager"] ?? "",
      managerId: json["manager_id"] ?? 0,
      location: json["location"] ?? "",
      pincode: json["pincode"] ?? "",
      details: json["details"] ?? "",
      deletedAt: json["deleted_at"],
      createdAt: json["created_at"] != null
          ? DateTime.tryParse(json["created_at"])
          : null,
      updatedAt: json["updated_at"] != null
          ? DateTime.tryParse(json["updated_at"])
          : null,
      vendorId: json["vendor_id"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "address": address,
    "manager": manager,
    "manager_id": managerId,
    "location": location,
    "pincode": pincode,
    "details": details,
    "deleted_at": deletedAt,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "vendor_id": vendorId,
  };
}
