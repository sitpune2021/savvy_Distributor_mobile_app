import 'package:distributor/utils/colors.dart';
import 'package:flutter/material.dart';

class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({super.key});

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

                Expanded(
                  child: ListView(
                    children: const [
                      OrderCard(
                        orderId: 4,
                        status: "PENDING",
                        date: "2026-04-22",
                        available: 30,
                        requiredQty: 25,
                        remaining: 5,
                      ),
                      OrderCard(
                        orderId: 3,
                        status: "PENDING",
                        date: "2026-04-22",
                        available: 30,
                        requiredQty: 25,
                        remaining: 5,
                      ),
                      OrderCard(
                        orderId: 2,
                        status: "DISPATCHED",
                        date: "2026-04-21",
                        available: 35,
                        requiredQty: 25,
                        remaining: 10,
                      ),
                    ],
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
          Icon(Icons.tune, color: Colors.blue.shade700),
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
