import 'package:distributor/widgets/logout_alert.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/colors.dart';
import '../router/app_routes.dart';

class AppDrawer extends StatefulWidget {
  final String currentRoute;

  const AppDrawer({super.key, required this.currentRoute});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String name = "";
  String email = "";

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      name = prefs.getString("name") ?? "";
      email = prefs.getString("email") ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // 🔵 MODERN HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: const BoxDecoration(color: AppColors.primary),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 35, color: AppColors.primary),
                ),
                SizedBox(height: 10),
                Text(
                  name.isNotEmpty ? name : "User",
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),

                Text(
                  email.isNotEmpty ? email : "",
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 🔹 MENU ITEMS
          _buildItem(
            context,
            icon: Icons.home,
            title: "Home",
            route: AppRoutes.dashboard,
          ),

          _buildItem(
            context,
            icon: Icons.shopping_cart,
            title: "Orders",
            route: AppRoutes.ordersList,
          ),

          _buildItem(
            context,
            icon: Icons.people,
            title: "Customers",
            route: "/customers",
          ),

          const Spacer(),

          const Divider(),

          _buildItem(
            context,
            icon: Icons.logout,
            title: "Logout",
            route: "/logout",
          ),

          const SizedBox(height: 10),

          // 📱 APP VERSION
          const Padding(
            padding: EdgeInsets.only(bottom: 15),
            child: Text(
              "App Version 1.0.0",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 Drawer Item Widget
  Widget _buildItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
  }) {
    bool isSelected = widget.currentRoute == route;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: isSelected
            ? AppColors.primary.withValues(alpha: 0.1)
            : Colors.transparent,

        leading: Icon(
          icon,
          color: isSelected ? AppColors.primary : Colors.black54,
        ),

        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppColors.primary : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),

        onTap: () {
          Navigator.pop(context);

          if (route == "/logout") {
            showLogoutDialog(context);

            return;
          }

          if (widget.currentRoute != route) {
            Navigator.pushNamed(context, route);
          }
        },
      ),
    );
  }
}
