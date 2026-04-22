import 'package:distributor/models/order_summary_model.dart';
import 'package:distributor/router/app_routes.dart';
import 'package:distributor/services/request_service.dart';
import 'package:distributor/utils/colors.dart';
import 'package:distributor/widgets/app_drawer.dart';
import 'package:distributor/widgets/buttom_status.dart';
import 'package:distributor/widgets/home_simmer.dart';
import 'package:distributor/widgets/status_card.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  OrderSummaryModel? summary;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadSummary();
  }

  Future<void> loadSummary() async {
    try {
      final data = await RequestService().getOrderSummary();
      setState(() {
        summary = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const AppDrawer(currentRoute: AppRoutes.dashboard),
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text("Home", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Icon(Icons.account_circle, size: 28, color: Colors.white),
          SizedBox(width: 10),
        ],
      ),

      body: isLoading
          ? const HomeShimmer()
          : LayoutBuilder(
              builder: (context, constraints) {
                double width = constraints.maxWidth;

                bool isMobile = width < 600;
                // bool isTablet = width < 1024;

                double padding = isMobile ? 16 : 24;

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: loadSummary,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),

                    child: Padding(
                      padding: EdgeInsets.all(padding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🔥 ORDER REQUEST CARD
                          InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.orderRequest,
                              );
                            },

                            child: Container(
                              width: double.infinity,

                              // padding: const EdgeInsets.all(20),
                              padding: EdgeInsets.all(isMobile ? 20 : 28),

                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                // gradient: const LinearGradient(
                                //   colors: [
                                //     Color(0xFF2563EB),
                                //     Color(0xFF60A5FA),
                                //   ],
                                // ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.add_shopping_cart_outlined,
                                    color: Colors.white,
                                    size: isMobile ? 36 : 44,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "New Order Requests",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isMobile ? 18 : 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    "Review and process incoming fulfillment tasks",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: const Text("Create New Order"),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // 🔹 HEADER
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                "Order Overview",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              // Text("Today", style: TextStyle(color: Colors.blue)),
                            ],
                          ),

                          const SizedBox(height: 5),
                          Container(
                            height: 90,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // 🔵 LEFT FLOATING BLUE PILL
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 10,
                                    top: 14,
                                    bottom: 14,
                                  ),
                                  child: Container(
                                    width: 4,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary, // your blue
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 14),

                                // 📝 TEXT CONTENT
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Total Orders",
                                        style: TextStyle(
                                          color: Colors.black45,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        "${summary?.orders.total ?? 0}",
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // 📊 ICON BOX
                                Padding(
                                  padding: const EdgeInsets.only(right: 16),
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFFEEF2FF,
                                      ), // light blue-purple tint
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.bar_chart_rounded,
                                      color: AppColors.primary,
                                      size: 22,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          // 🔹 GRID (Responsive)
                          GridView.count(
                            crossAxisCount: 3,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: isMobile ? 1 : 1.2,
                            children: [
                              StatusCard(
                                "${summary?.orders.pending ?? 0}",
                                "Pending",
                                Icons.access_time,
                                Colors.orange,
                              ),
                              StatusCard(
                                "${summary?.orders.dispatched ?? 0}",
                                "Dispatched",
                                Icons.local_shipping,
                                AppColors.primary,
                              ),
                              StatusCard(
                                "${summary?.orders.approved ?? 0}",
                                "Approved",
                                Icons.check_circle,
                                Colors.grey,
                              ),
                              StatusCard(
                                "${summary?.orders.inProduction ?? 0}",
                                "Production",
                                Icons.precision_manufacturing,
                                Colors.grey,
                              ),
                              StatusCard(
                                "${summary?.orders.productionCompleted ?? 0}",
                                "Completed",
                                Icons.inventory,
                                Colors.grey,
                              ),
                              StatusCard(
                                "${summary?.orders.delivered ?? 0}",
                                "Delivered",
                                Icons.done_all,
                                Colors.grey,
                              ),
                            ],
                          ),
                          // 🔹 CLOSED / REJECTED
                          Row(
                            children: [
                              Expanded(
                                child: BottomStatus(
                                  "Closed",
                                  "${summary?.orders.closed ?? 0}",
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: BottomStatus(
                                  "Rejected",
                                  "${summary?.orders.rejected ?? 0}",
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Plant Stock",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white, // ✅ whole card = white
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.05,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    // 🔹 TOP PART — Grey background
                                    Container(
                                      decoration: const BoxDecoration(
                                        color: Color(
                                          0xFFF1F5F9,
                                        ), // ✅ grey only here
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          topRight: Radius.circular(16),
                                        ),
                                      ),
                                      padding: const EdgeInsets.all(14),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Icon(
                                              Icons.home,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Total Empty Jars",
                                                style: TextStyle(
                                                  color: Colors.black54,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                "${summary?.plantStock.totalEmptyJars ?? 0}",
                                                style: TextStyle(
                                                  fontSize: 26,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    const Divider(height: 1),

                                    // 🔹 BOTTOM PART — White background
                                    Padding(
                                      padding: const EdgeInsets.all(14),
                                      child: Column(
                                        children:
                                            (summary
                                                    ?.plantStock
                                                    .plants
                                                    .isNotEmpty ??
                                                false)
                                            ? summary!.plantStock.plants.map((
                                                plant,
                                              ) {
                                                // ✅ SAFE calculation (no crash)
                                                final totalJars =
                                                    summary
                                                        ?.plantStock
                                                        .totalEmptyJars ??
                                                    0;

                                                double progress = totalJars == 0
                                                    ? 0
                                                    : plant.remainingEmptyJars /
                                                          totalJars;

                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        bottom: 12,
                                                      ),
                                                  child: Row(
                                                    children: [
                                                      CircleAvatar(
                                                        radius: 22,
                                                        backgroundColor: Colors
                                                            .green
                                                            .shade100,
                                                        child: const Icon(
                                                          Icons.eco,
                                                          color: Colors.green,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),

                                                      /// 🔹 TEXT (NO UI CHANGE)
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              plant
                                                                  .plantName, // ✅ dynamic
                                                              style: const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 4,
                                                            ),
                                                            const Text(
                                                              "Remaining Empty Jars",
                                                              style: TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),

                                                      /// 🔹 RIGHT SIDE (NO UI CHANGE)
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        children: [
                                                          Text(
                                                            "${plant.remainingEmptyJars}", // ✅ dynamic
                                                            style:
                                                                const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: AppColors
                                                                      .primary,
                                                                ),
                                                          ),
                                                          const SizedBox(
                                                            height: 6,
                                                          ),
                                                          Container(
                                                            width: 80,
                                                            height: 6,
                                                            decoration:
                                                                BoxDecoration(
                                                                  color: Colors
                                                                      .blue
                                                                      .shade100,
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        10,
                                                                      ),
                                                                ),
                                                            child: FractionallySizedBox(
                                                              widthFactor:
                                                                  progress.clamp(
                                                                    0.0,
                                                                    1.0,
                                                                  ), // ✅ dynamic bar
                                                              child: Container(
                                                                decoration: BoxDecoration(
                                                                  color: AppColors
                                                                      .primary,
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        10,
                                                                      ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }).toList()
                                            : [
                                                /// ✅ EMPTY STATE (no crash, no blank UI)
                                                const Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: 20,
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "No plant data available",
                                                      style: TextStyle(
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
