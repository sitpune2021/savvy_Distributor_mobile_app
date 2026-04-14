// import 'package:distributor/services/api_services.dart';
// import 'package:flutter/material.dart';

// void showLogoutDialog(BuildContext context) {
//   showGeneralDialog(
//     context: context,
//     barrierDismissible: true,
//     barrierLabel: "Logout",
//     barrierColor: Colors.black.withOpacity(0.4),
//     transitionDuration: const Duration(milliseconds: 300),

//     pageBuilder: (context, animation, secondaryAnimation) {
//       return const SizedBox();
//     },

//     transitionBuilder: (context, animation, secondaryAnimation, child) {
//       return Transform.scale(
//         scale: Curves.easeInOut.transform(animation.value),
//         child: Opacity(
//           opacity: animation.value,
//           child: const _LogoutDialogUI(),
//         ),
//       );
//     },
//   );
// }

// class _LogoutDialogUI extends StatelessWidget {
//   const _LogoutDialogUI();

//   @override
//   Widget build(BuildContext context) {
//     double width = MediaQuery.of(context).size.width;
//     double dialogWidth = width < 600 ? width * 0.85 : 400;

//     return Center(
//       child: Material(
//         color: Colors.transparent,
//         child: Container(
//           width: dialogWidth,
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // ICON
//               Container(
//                 padding: const EdgeInsets.all(15),
//                 decoration: BoxDecoration(
//                   color: Colors.red.withValues(alpha: .1),
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(Icons.logout, color: Colors.red, size: 30),
//               ),

//               const SizedBox(height: 15),

//               const Text(
//                 "Logout",
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),

//               const SizedBox(height: 10),

//               const Text(
//                 "Are you sure you want to logout?",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(color: Colors.grey),
//               ),

//               const SizedBox(height: 20),

//               Row(
//                 children: [
//                   // CANCEL
//                   Expanded(
//                     child: OutlinedButton(
//                       onPressed: () => Navigator.pop(context),
//                       child: const Text("Cancel"),
//                     ),
//                   ),

//                   const SizedBox(width: 10),

//                   // LOGOUT
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: () async {
//                         Navigator.pop(context);
//                         await AuthService.logout(context);
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.red,
//                       ),
//                       child: const Text("Logout"),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:distributor/services/api_services.dart';
import 'package:distributor/utils/colors.dart';
import 'package:flutter/material.dart';

void showLogoutDialog(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Logout",
    barrierColor: Colors.black.withOpacity(0.4),
    transitionDuration: const Duration(milliseconds: 300),

    pageBuilder: (context, animation, secondaryAnimation) {
      return const SizedBox();
    },

    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return Transform.scale(
        scale: Curves.easeInOut.transform(animation.value),
        child: Opacity(
          opacity: animation.value,
          child: const _LogoutDialogUI(),
        ),
      );
    },
  );
}

class _LogoutDialogUI extends StatelessWidget {
  const _LogoutDialogUI();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double dialogWidth = width < 600 ? width * 0.85 : 400;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: dialogWidth,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔵 ICON (BLUE THEME)
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout,
                  color: AppColors.primary,
                  size: 30,
                ),
              ),

              const SizedBox(height: 15),

              // 🔵 TITLE
              const Text(
                "Logout",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 10),

              // 🔵 MESSAGE
              const Text(
                "Are you sure you want to logout?",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  // ❌ CANCEL BUTTON
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // 🔵 LOGOUT BUTTON
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await AuthService.logout(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Logout",
                        style: TextStyle(
                          color: Colors.white, // ✅ FIXED
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
