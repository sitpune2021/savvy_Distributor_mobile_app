import 'package:distributor/models/orders_list_model.dart';
import 'package:distributor/services/request_service.dart';
import 'package:distributor/utils/colors.dart';
import 'package:flutter/material.dart';

class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({super.key});

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  final RequestService _service = RequestService();
  final ScrollController _scrollController = ScrollController();

  List<Order> orders = [];

  bool isLoading = true;
  bool isMoreLoading = false;
  bool _isFetchingMore = false;

  int currentPage = 1;
  int lastPage = 1;
  int _fetchGeneration = 0;

  String selectedStatus = ""; // "" = ALL

  final List<String> statuses = [
    "",
    "pending",
    "approved",
    "in_production",
    "production_completed",
    "dispatched",
    "delivered",
    "closed",
    "rejected",
  ];

  @override
  void initState() {
    super.initState();

    fetchOrders();

    // ✅ ScrollController listener — triggers load more near bottom
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isFetchingMore &&
          currentPage <= lastPage) {
        fetchOrders(isLoadMore: true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchOrders({bool isLoadMore = false}) async {
    // ✅ For filter/refresh: force-reset the guard
    if (!isLoadMore) {
      _isFetchingMore = false;
      _fetchGeneration++; // invalidate any in-flight responses
    }

    if (_isFetchingMore) return;

    // ✅ Capture generation at call time
    final generation = _fetchGeneration;

    // ✅ Capture status locally at call time — avoids stale closure bug
    final statusAtCallTime = selectedStatus;

    if (isLoadMore) {
      if (currentPage > lastPage) return;
      _isFetchingMore = true;
      setState(() => isMoreLoading = true);
    } else {
      setState(() {
        isLoading = true;
        currentPage = 1;
        orders.clear();
      });
    }

    try {
      final data = await _service.getOrders(
        status: statusAtCallTime.isEmpty ? null : statusAtCallTime,
        page: currentPage,
      );

      // ✅ Discard if a newer fetch has started
      if (generation != _fetchGeneration) return;

      setState(() {
        orders.addAll(data.orders);
        lastPage = data.lastPage;
        currentPage++;
      });
    } catch (e) {
      if (generation != _fetchGeneration) return;
      debugPrint(e.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (generation == _fetchGeneration && mounted) {
        setState(() {
          isLoading = false;
          isMoreLoading = false;
          _isFetchingMore = false;
        });
      }
    }
  }

  // ✅ Pull-to-refresh handler
  Future<void> _onRefresh() async {
    await fetchOrders();
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: statuses.length,
        itemBuilder: (context, index) {
          final status = statuses[index];
          final isSelected = selectedStatus == status;

          return GestureDetector(
            onTap: () {
              if (selectedStatus == status) {
                return; // ✅ Skip if already selected
              }

              // ✅ Block scroll listener from firing old-status fetch
              _isFetchingMore = true;

              setState(() => selectedStatus = status);
              fetchOrders();
            },

            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  // status.isEmpty ? "ALL" : status.toUpperCase(),
                  status.isEmpty
                      ? "ALL"
                      : status.replaceAll("_", " ").toUpperCase(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ✅ Empty state widget
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 72, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            "No orders found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            selectedStatus.isEmpty
                ? "You have no orders yet."
                : "No orders with status \"${selectedStatus.replaceAll("_", " ")}\".",
            style: TextStyle(color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: () => fetchOrders(),
            icon: const Icon(Icons.refresh),
            label: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text("Home", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: const [
          Icon(Icons.account_circle, size: 28, color: Colors.white),
          SizedBox(width: 10),
        ],
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          double width = constraints.maxWidth;

          bool isMobile = width < 600;
          double padding = isMobile ? 16 : 24;

          return Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              children: [
                _buildSearchBar(),
                const SizedBox(height: 12),

                /// ✅ FILTER (added, UI not changed)
                _buildFilters(),
                const SizedBox(height: 10),

                Expanded(
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        )
                      : orders.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          // ✅ Pull-to-refresh
                          onRefresh: _onRefresh,
                          color: AppColors.primary,
                          child: ListView.builder(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            // itemCount: orders.length + 1,
                            itemCount: orders.length + (isMoreLoading ? 1 : 0),
                            itemBuilder: (context, index) {
                              /// 🔥 Pagination trigger
                              if (index == orders.length) {
                                // if (!isMoreLoading && currentPage <= lastPage) {
                                //   fetchOrders(isLoadMore: true);
                                //   return const Center(
                                //     child: CircularProgressIndicator(
                                //       color: AppColors.primary,
                                //     ),
                                //   );
                                // }
                                // return const SizedBox();
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                );
                              }

                              final order = orders[index];

                              return OrderCard(
                                orderId: order.id,
                                status: order.status.toUpperCase(),
                                date: order.createdAt
                                    .toString()
                                    .split(" ")
                                    .first,
                                available: order.summary.available,
                                requiredQty: order.summary.requiredQty,
                                remaining: order.summary.remaining,
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 8),
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search orders...",
                border: InputBorder.none,
              ),
            ),
          ),
          // Icon(Icons.tune, color: Colors.blue.shade700),
        ],
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final int orderId;
  final String status;
  final String date;
  final int available;
  final int requiredQty;
  final int remaining;

  const OrderCard({
    super.key,
    required this.orderId,
    required this.status,
    required this.date,
    required this.available,
    required this.requiredQty,
    required this.remaining,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = status == "PENDING";

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Top Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    "Order #$orderId",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _statusBadge(status),
                ],
              ),
              Text(date, style: const TextStyle(color: Colors.grey)),
            ],
          ),

          const SizedBox(height: 6),

          /// Plant
          Row(
            children: const [
              Icon(Icons.factory, size: 18, color: Colors.black54),
              SizedBox(width: 6),
              Text("plant"),
            ],
          ),

          const Divider(height: 20),

          /// Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _stat("Available", available, Colors.blue),
              _divider(),
              _stat("Required", requiredQty, Colors.blueAccent),
              _divider(),
              _stat("Remaining", remaining, Colors.black),
            ],
          ),

          const Divider(height: 20),

          /// Bottom Action
          Align(
            alignment: Alignment.centerRight,
            child: isPending
                ? const Text(
                    "View Details  >",
                    style: TextStyle(color: Colors.blue),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        "Track Shipment",
                        style: TextStyle(color: Colors.blue),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.local_shipping, size: 18, color: Colors.blue),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    final isPending = status == "PENDING";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPending ? Colors.orange.shade50 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isPending ? Colors.orange : Colors.blue),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: isPending ? Colors.orange : Colors.blue,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _stat(String title, int value, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(height: 30, width: 1, color: Colors.grey.shade300);
  }
}
