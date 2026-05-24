import 'package:doancuoiki/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class AppSnackbar {
  // SUCCESS
  static void showSuccess(BuildContext context, String message) {
    _show(context, message, Icons.check_circle_rounded, Colors.green);
  }

  // ERROR
  static void showError(BuildContext context, String message) {
    _show(context, message, Icons.error_rounded, Colors.red);
  }

  // INFO
  static void showInfo(BuildContext context, String message) {
    _show(context, message, Icons.info_rounded, AppColors.accent1);
  }

  // MAIN
  static void _show(
    BuildContext context,
    String message,
    IconData icon,
    Color color,
  ) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,

        backgroundColor: Colors.white,

        elevation: 0,

        margin: const EdgeInsets.all(16),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

        duration: const Duration(seconds: 2),

        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),

              decoration: BoxDecoration(
                color: color.withOpacity(0.1),

                shape: BoxShape.circle,
              ),

              child: Icon(icon, color: color, size: 22),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                message,

                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
