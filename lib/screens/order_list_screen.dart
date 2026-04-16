import 'package:distributor/screens/order_tab/approval_order_screen.dart';
import 'package:distributor/screens/order_tab/pending_order_scren.dart';
import 'package:distributor/utils/colors.dart';
import 'package:flutter/material.dart';

class OrderListScreen extends StatelessWidget {
  final int initialTab;

  const OrderListScreen({super.key, this.initialTab = 0});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Pending & Approval
      initialIndex: initialTab,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "Plant Operations",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.w600),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: "Pending"),
              Tab(text: "Approval"),
            ],
          ),
        ),

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
                child: const TabBarView(
                  children: [PendingOrderScreen(), ApprovalScreen()],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
