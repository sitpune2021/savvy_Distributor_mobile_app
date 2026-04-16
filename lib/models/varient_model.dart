import 'dart:convert';

VariantModel variantModelFromJson(String str) =>
    VariantModel.fromJson(json.decode(str));

String variantModelToJson(VariantModel data) => json.encode(data.toJson());

class VariantModel {
  final bool status;
  final String message;
  final List<VariantData> data;

  VariantModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory VariantModel.fromJson(Map<String, dynamic> json) {
    return VariantModel(
      status: json["status"] ?? false,
      message: json["message"] ?? "",
      data: json["data"] == null
          ? []
          : List<VariantData>.from(
              json["data"].map((x) => VariantData.fromJson(x)),
            ),
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data.map((x) => x.toJson()).toList(),
  };
}

class VariantData {
  // final int labelId;
  final String variantName;
  final int id;
  final bool disable;

  VariantData({
    // required this.labelId,
    required this.variantName,
    required this.id,
    required this.disable,
  });

  factory VariantData.fromJson(Map<String, dynamic> json) {
    return VariantData(
      // labelId: json["label_id"] ?? 0,
      variantName: json["variant_name"] ?? "",
      id: json["id"] ?? 0,
      disable: json["disable"] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    // "label_id": labelId,
    "variant_name": variantName,
    "id": id,
    "disable": disable,
  };
}
