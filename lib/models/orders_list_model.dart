import 'dart:convert';

OrdersListModel ordersListModelFromJson(String str) =>
    OrdersListModel.fromJson(json.decode(str));

String ordersListModelToJson(OrdersListModel data) =>
    json.encode(data.toJson());

class OrdersListModel {
  final bool success;
  final OrderData data;

  OrdersListModel({required this.success, required this.data});

  factory OrdersListModel.fromJson(Map<String, dynamic> json) =>
      OrdersListModel(
        success: json["success"] ?? false,
        data: OrderData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"success": success, "data": data.toJson()};
}

class OrderData {
  final int currentPage;
  final List<Order> orders;
  final String firstPageUrl;
  final int from;
  final int lastPage;
  final String lastPageUrl;
  final List<PaginationLink> links;
  final String? nextPageUrl;
  final String path;
  final int perPage;
  final String? prevPageUrl;
  final int to;
  final int total;

  OrderData({
    required this.currentPage,
    required this.orders,
    required this.firstPageUrl,
    required this.from,
    required this.lastPage,
    required this.lastPageUrl,
    required this.links,
    required this.nextPageUrl,
    required this.path,
    required this.perPage,
    required this.prevPageUrl,
    required this.to,
    required this.total,
  });

  factory OrderData.fromJson(Map<String, dynamic> json) => OrderData(
    currentPage: json["current_page"] ?? 0,
    orders: List<Order>.from(
      (json["data"] ?? []).map((x) => Order.fromJson(x)),
    ),
    firstPageUrl: json["first_page_url"] ?? "",
    from: json["from"] ?? 0,
    lastPage: json["last_page"] ?? 0,
    lastPageUrl: json["last_page_url"] ?? "",
    links: List<PaginationLink>.from(
      (json["links"] ?? []).map((x) => PaginationLink.fromJson(x)),
    ),
    nextPageUrl: json["next_page_url"],
    path: json["path"] ?? "",
    perPage: json["per_page"] ?? 0,
    prevPageUrl: json["prev_page_url"],
    to: json["to"] ?? 0,
    total: json["total"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "data": orders.map((x) => x.toJson()).toList(),
    "first_page_url": firstPageUrl,
    "from": from,
    "last_page": lastPage,
    "last_page_url": lastPageUrl,
    "links": links.map((x) => x.toJson()).toList(),
    "next_page_url": nextPageUrl,
    "path": path,
    "per_page": perPage,
    "prev_page_url": prevPageUrl,
    "to": to,
    "total": total,
  };
}

class Order {
  final int id;
  final String status;
  final Plantss plant;
  final Summary summary;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.status,
    required this.plant,
    required this.summary,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json["id"] ?? 0,
    status: json["status"] ?? "",
    plant: Plantss.fromJson(json["plant"] ?? {}),
    summary: Summary.fromJson(json["summary"] ?? {}),
    createdAt: DateTime.parse(json["created_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "status": status,
    "plant": plant.toJson(),
    "summary": summary.toJson(),
    "created_at": createdAt.toIso8601String(),
  };
}

class Plantss {
  final int id;
  final String name;

  Plantss({required this.id, required this.name});

  factory Plantss.fromJson(Map<String, dynamic> json) =>
      Plantss(id: json["id"] ?? 0, name: json["name"] ?? "");

  Map<String, dynamic> toJson() => {"id": id, "name": name};
}

class Summary {
  final int available;
  final int requiredQty;
  final int remaining;

  Summary({
    required this.available,
    required this.requiredQty,
    required this.remaining,
  });

  factory Summary.fromJson(Map<String, dynamic> json) => Summary(
    available: json["available"] ?? 0,
    requiredQty: json["required"] ?? 0,
    remaining: json["remaining"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "available": available,
    "required": requiredQty,
    "remaining": remaining,
  };
}

class PaginationLink {
  final String? url;
  final String label;
  final bool active;

  PaginationLink({
    required this.url,
    required this.label,
    required this.active,
  });

  factory PaginationLink.fromJson(Map<String, dynamic> json) => PaginationLink(
    url: json["url"],
    label: json["label"] ?? "",
    active: json["active"] ?? false,
  );

  Map<String, dynamic> toJson() => {
    "url": url,
    "label": label,
    "active": active,
  };
}
