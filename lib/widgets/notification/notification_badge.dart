// Badge nho cho icon chuong thong bao.
// Cach dung:
//   NotificationBadge(child: Icon(Icons.notifications_none_rounded))
//
// Tu watch NotificationProvider.unreadCount va render so do chuong.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../data/providers/notification_provider.dart';

class NotificationBadge extends StatelessWidget {
  final Widget child;
  final double size; // duong kinh badge
  final bool showZero;

  const NotificationBadge({
    super.key,
    required this.child,
    this.size = 16,
    this.showZero = false,
  });

  @override
  Widget build(BuildContext context) {
    final count = context.watch<NotificationProvider>().unreadCount;
    final visible = showZero || count > 0;
    final label = count > 99 ? '99+' : count.toString();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (visible)
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              constraints: BoxConstraints(
                minWidth: size,
                minHeight: size,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: AppColors.accent1,
                borderRadius: BorderRadius.circular(size),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
