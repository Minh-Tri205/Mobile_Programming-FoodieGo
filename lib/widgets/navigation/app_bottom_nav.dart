import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;

  const AppBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: '🏠',
            label: 'Trang chủ',
            isActive: currentIndex == 0,
            onTap: () => _navigate(context, 0),
          ),
          _NavItem(
            icon: '🔍',
            label: 'Tìm kiếm',
            isActive: currentIndex == 1,
            onTap: () => _navigate(context, 1),
          ),
          _NavItem(
            icon: '📋',
            label: 'Đơn hàng',
            isActive: currentIndex == 2,
            onTap: () => _navigate(context, 2),
          ),
          _NavItem(
            icon: '👤',
            label: 'Hồ sơ',
            isActive: currentIndex == 3,
            onTap: () => _navigate(context, 3),
          ),
        ],
      ),
    );
  }

  void _navigate(BuildContext context, int index) {
    if (index == currentIndex) return;
    final routes = [
      AppRoutes.home,
      AppRoutes.search,
      AppRoutes.orders,
      AppRoutes.profile,
    ];
    Navigator.pushNamedAndRemoveUntil(
      context,
      routes[index],
      (route) => false,
    );
  }
}

class _NavItem extends StatelessWidget {
  final String icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.pastel1 : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? AppColors.accent1 : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
