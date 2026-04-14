import 'package:distributor/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent, // keep your design
        elevation: 0,

        // 🔥 FIX STATUS BAR
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent, // keeps gradient look
          statusBarIconBrightness: Brightness.dark, // 🔋 icons black
          statusBarBrightness: Brightness.light,
        ),

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double width = constraints.maxWidth;

          bool isMobile = width < 600;
          bool isTablet = width < 1024;

          double containerWidth = isMobile
              ? double.infinity
              : (isTablet ? 500 : 420);

          double padding = isMobile ? 16 : 24;
          double titleSize = isMobile ? 26 : 32;

          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: SizedBox(
                  width: containerWidth,
                  child: Column(
                    children: [
                      // 🔥 HEADER
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(padding),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF2563EB), Color(0xFF60A5FA)],
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [],
                            ),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: .2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.lock_reset,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(height: 10),

                            Text(
                              "Update credentials",
                              style: TextStyle(
                                fontSize: titleSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(height: 8),

                            const Text(
                              "Reset your password securely",
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),

                      // 🔳 FORM
                      Padding(
                        padding: EdgeInsets.all(padding),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("EMAIL ADDRESS"),
                              const SizedBox(height: 8),

                              TextField(
                                controller: emailController,
                                decoration: InputDecoration(
                                  hintText: "name@company.com",
                                  filled: true,
                                  fillColor: const Color(0xFFF1F5F9),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              const Text("NEW PASSWORD"),
                              const SizedBox(height: 8),

                              TextField(
                                controller: passwordController,
                                obscureText: obscureText,
                                decoration: InputDecoration(
                                  hintText: "••••••••",
                                  filled: true,
                                  fillColor: const Color(0xFFF1F5F9),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
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
                                ),
                              ),

                              const SizedBox(height: 20),

                              SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () {},
                                  child: const Text(
                                    "Reset Password",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
