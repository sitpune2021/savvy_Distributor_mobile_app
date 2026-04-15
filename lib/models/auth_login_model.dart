import 'dart:convert';

DistributorModel distributorModelFromJson(String str) {
  try {
    return DistributorModel.fromJson(json.decode(str));
  } catch (e) {
    throw Exception("DistributorModel parsing error: $e");
  }
}

String distributorModelToJson(DistributorModel data) {
  try {
    return json.encode(data.toJson());
  } catch (e) {
    throw Exception("DistributorModel encoding error: $e");
  }
}

class DistributorModel {
  final bool status;
  final String message;
  final Data? data;

  DistributorModel({required this.status, required this.message, this.data});

  factory DistributorModel.fromJson(Map<String, dynamic> json) {
    return DistributorModel(
      status: json["status"] ?? false,
      message: json["message"] ?? "",
      data: json["data"] != null ? Data.fromJson(json["data"]) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class Data {
  final Distributor? distributor;
  final String token;

  Data({this.distributor, required this.token});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      distributor: json["distributor"] != null
          ? Distributor.fromJson(json["distributor"])
          : null,
      token: json["token"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "distributor": distributor?.toJson(),
    "token": token,
  };
}

class Distributor {
  final int id;
  final String zohoId;
  final String name;
  final String email;
  final String password;
  final String phoneNo;
  final String fullAddress;
  final String country;
  final String state;
  final String city;
  final String pincode;
  final String poNo;

  final String? licenseNo;
  final String? tempoNo;
  final String? tempoName;
  final String? panCard;
  final String? aadharCard;
  final String? panCardFile;
  final String? aadharCardFile;
  final String? deletedAt;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  Distributor({
    required this.id,
    required this.zohoId,
    required this.name,
    required this.email,
    required this.password,
    required this.phoneNo,
    required this.fullAddress,
    required this.country,
    required this.state,
    required this.city,
    required this.pincode,
    required this.poNo,
    this.licenseNo,
    this.tempoNo,
    this.tempoName,
    this.panCard,
    this.aadharCard,
    this.panCardFile,
    this.aadharCardFile,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory Distributor.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(String? value) {
      try {
        return value != null ? DateTime.parse(value) : null;
      } catch (_) {
        return null;
      }
    }

    return Distributor(
      id: json["id"] ?? 0,
      zohoId: json["zoho_id"] ?? "",
      name: json["name"] ?? "",
      email: json["email"] ?? "",
      password: json["password"] ?? "",
      phoneNo: json["phone_no"] ?? "",
      fullAddress: json["full_address"] ?? "",
      country: json["country"] ?? "",
      state: json["state"] ?? "",
      city: json["city"] ?? "",
      pincode: json["pincode"] ?? "",
      poNo: json["po_no"] ?? "",

      licenseNo: json["license_no"]?.toString(),
      tempoNo: json["tempo_no"]?.toString(),
      tempoName: json["tempo_name"]?.toString(),
      panCard: json["pan_card"]?.toString(),
      aadharCard: json["aadhar_card"]?.toString(),
      panCardFile: json["pan_card_FILE"]?.toString(),
      aadharCardFile: json["aadhar_card_FILE"]?.toString(),
      deletedAt: json["deleted_at"]?.toString(),

      createdAt: parseDate(json["created_at"]),
      updatedAt: parseDate(json["updated_at"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "zoho_id": zohoId,
    "name": name,
    "email": email,
    "password": password,
    "phone_no": phoneNo,
    "full_address": fullAddress,
    "country": country,
    "state": state,
    "city": city,
    "pincode": pincode,
    "po_no": poNo,
    "license_no": licenseNo,
    "tempo_no": tempoNo,
    "tempo_name": tempoName,
    "pan_card": panCard,
    "aadhar_card": aadharCard,
    "pan_card_FILE": panCardFile,
    "aadhar_card_FILE": aadharCardFile,
    "deleted_at": deletedAt,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}
