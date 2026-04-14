import 'package:distributor/widgets/logout_alert.dart';
import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../router/app_routes.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;

  const AppDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // 🔵 MODERN HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF60A5FA)],
              ),
            ),
            child: const Column(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 35, color: AppColors.primary),
                ),
                SizedBox(height: 10),
                Text(
                  "John Doe",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                Text(
                  "john@example.com",
                  style: TextStyle(color: Colors.white70),
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
            route: "/orders",
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
    bool isSelected = currentRoute == route;

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

          if (currentRoute != route) {
            Navigator.pushReplacementNamed(context, route);
          }
        },
      ),
    );
  }
}
