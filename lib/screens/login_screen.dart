// ignore_for_file: deprecated_member_use

import 'package:distributor/router/app_routes.dart';
import 'package:distributor/utils/colors.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscureText = true;

  // 🔵 Main Blue Color
  // final Color primaryBlue = const Color(0xFF2563EB);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // 🚫 Disable back
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            double width = constraints.maxWidth;

            bool isMobile = width < 600;
            bool isTablet = width >= 600 && width < 1024;

            double containerWidth = isMobile
                ? double.infinity
                : isTablet
                ? 500
                : 400;

            double padding = isMobile ? 16 : 24;
            double titleSize = isMobile ? 28 : 34;

            return Center(
              child: SingleChildScrollView(
                child: Container(
                  width: containerWidth,
                  color: const Color(0xFFF5F6FA),
                  child: Column(
                    children: [
                      // 🔥 HEADER (BLUE GRADIENT)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          vertical: padding * 2,
                          horizontal: padding,
                        ),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF2563EB), Color(0xFF60A5FA)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Column(
                          children: [
                            // const SizedBox(height: 20),

                            // const Text(
                            //   "Distributor App",
                            //   style: TextStyle(
                            //     fontSize: 16,
                            //     letterSpacing: 1.5,
                            //     color: Colors.white70,
                            //   ),
                            // ),

                            // const SizedBox(height: 10),
                            Text(
                              "Welcome Back 👋",
                              style: TextStyle(
                                fontSize: titleSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(height: 10),

                            const Text(
                              "Login to continue",
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),

                      // 🔥 FORM
                      Padding(
                        padding: EdgeInsets.all(padding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("EMAIL ADDRESS"),
                            const SizedBox(height: 8),

                            // EMAIL FIELD
                            TextField(
                              controller: emailController,
                              decoration: InputDecoration(
                                hintText: "name@email.com",
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                  color: AppColors.primary,
                                ),

                                filled: true,
                                fillColor: Colors.white,

                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
                                ),

                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            const Text("PASSWORD"),
                            const SizedBox(height: 8),

                            // PASSWORD FIELD
                            TextField(
                              controller: passwordController,
                              obscureText: obscureText,
                              decoration: InputDecoration(
                                hintText: "••••••••",
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: AppColors.primary,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    obscureText
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: AppColors.primary,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      obscureText = !obscureText;
                                    });
                                  },
                                ),

                                filled: true,
                                fillColor: Colors.white,

                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
                                ),

                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            // FORGOT PASSWORD
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.resetPassword,
                                  );
                                },
                                child: Text(
                                  "Forgot Password?",
                                  style: TextStyle(color: AppColors.primary),
                                ),
                              ),
                            ),

                            const SizedBox(height: 30),

                            // 🔥 SIGN IN BUTTON
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  elevation: 6,
                                  shadowColor: AppColors.primary.withValues(
                                    alpha: 0.4,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.dashboard,
                                  );
                                },
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Sign In",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
