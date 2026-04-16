import 'dart:convert';

PlantModel plantModelFromJson(String str) {
  try {
    return PlantModel.fromJson(json.decode(str));
  } catch (e) {
    throw Exception("PlantModel parsing error: $e");
  }
}

String plantModelToJson(PlantModel data) {
  try {
    return json.encode(data.toJson());
  } catch (e) {
    throw Exception("PlantModel encoding error: $e");
  }
}

class PlantModel {
  final bool status;
  final List<Plant> data;

  PlantModel({required this.status, required this.data});

  factory PlantModel.fromJson(Map<String, dynamic> json) {
    return PlantModel(
      status: json["status"] ?? false,
      data: json["data"] != null
          ? List<Plant>.from(json["data"].map((x) => Plant.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": data.map((x) => x.toJson()).toList(),
  };
}

class Plant {
  final int id;
  final String name;

  Plant({required this.id, required this.name});

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(id: json["id"] ?? 0, name: json["name"] ?? "");
  }

  Map<String, dynamic> toJson() => {"id": id, "name": name};
}
