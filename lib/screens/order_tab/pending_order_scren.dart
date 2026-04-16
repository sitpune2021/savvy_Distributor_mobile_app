import 'package:distributor/models/order_list_model.dart';
import 'package:distributor/services/request_service.dart';
import 'package:distributor/utils/colors.dart';
import 'package:flutter/material.dart';

class PendingOrderScreen extends StatefulWidget {
  const PendingOrderScreen({super.key});

  @override
  State<PendingOrderScreen> createState() => _PendingOrderScreenState();
}

class _PendingOrderScreenState extends State<PendingOrderScreen> {
  List<PendingOrder> orders = [];
  bool isLoading = true;
  String error = "";

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  /// 🔄 FETCH DATA
  Future<void> fetchOrders() async {
    try {
      setState(() {
        isLoading = true;
        error = "";
      });

      final data = await RequestService().getPendingOrders();

      /// 👉 OPTIONAL FILTER (only pending)
      orders = data.where((e) => e.status.toLowerCase() == "pending").toList();
    } catch (e) {
      error = e.toString();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double width = constraints.maxWidth;
          final bool isMobile = width < 600;
          final bool isTablet = width < 1024;
          final double containerWidth = isMobile
              ? double.infinity
              : (isTablet ? 500 : 420);
          final double padding = isMobile ? 16 : 24;

          return Center(
            child: Container(
              width: containerWidth,
              padding: EdgeInsets.all(padding),
              child: RefreshIndicator(
                onRefresh: fetchOrders,
                child: _buildBody(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    /// 🔄 SHIMMER LOADING
    if (isLoading) {
      return ListView.builder(
        itemCount: 5,
        itemBuilder: (_, _) => const ShimmerCard(),
      );
    }

    /// ❌ ERROR
    if (error.isNotEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 200),
          Center(child: Text(error)),
        ],
      );
    }

    /// 📭 EMPTY
    if (orders.isEmpty) {
      return const Center(child: Text("No pending orders"));
    }

    /// ✅ DATA LIST
    return ListView.separated(
      itemCount: orders.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final order = orders[index];

        return OrderCard(
          plantName: order.plant?.name ?? "No Plant",
          required: "${order.requiredQuantity} units",
          status: order.status.toUpperCase(),
        );
      },
    );
  }
}

class OrderCard extends StatelessWidget {
  final String plantName;
  final String required;
  final String status;

  const OrderCard({
    super.key,
    required this.plantName,
    required this.required,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isApproved = status == "APPROVED";

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 90,
            color: isApproved ? AppColors.primary : Colors.transparent,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _label("Plant Name"),
                      _label("REQUIRED"),
                      _statusChip(status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          plantName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      Text(
                        required,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        color: AppColors.primary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _statusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: const TextStyle(
          fontSize: 11,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class ShimmerCard extends StatefulWidget {
  const ShimmerCard({super.key});

  @override
  State<ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<ShimmerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, _) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 90,
          decoration: BoxDecoration(
            color: Colors.grey.shade300.withValues(
              alpha: 0.4 + (_controller.value * 0.4),
            ),
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }
}
