import 'package:doancuoiki/core/constants/app_routes.dart';
import 'package:doancuoiki/views/admin/admin_categories_screen.dart';
import 'package:doancuoiki/views/admin/admin_dashboard_screen.dart';
import 'package:doancuoiki/views/admin/admin_orders_screen.dart';
import 'package:doancuoiki/views/admin/admin_products_screen.dart';
import 'package:doancuoiki/views/admin/admin_statistics_screen.dart';
import 'package:doancuoiki/views/admin/admin_users_screen.dart';
import 'package:doancuoiki/views/admin/admin_settings_screen.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.accent1, AppColors.accent5],
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.admin_panel_settings_rounded,
                    size: 34,
                    color: AppColors.accent1,
                  ),
                ),
                SizedBox(height: 12),
                Text('Quản trị viên', style: AppTextStyles.heading3),
                Text('admin@foodapp.com', style: AppTextStyles.bodyMuted),
              ],
            ),
          ),
          _buildDrawerItem(
            context,
            Icons.dashboard_rounded,
            'Dashboard',
            const AdminDashboardScreen(),
          ),
          _buildDrawerItem(
            context,
            Icons.receipt_long_rounded,
            'Đơn hàng',
            const AdminOrdersScreen(),
          ),
          _buildDrawerItem(
            context,
            Icons.fastfood_rounded,
            'Sản phẩm',
            const AdminProductsScreen(),
          ),
          _buildDrawerItem(
            context,
            Icons.category_rounded,
            'Danh mục',
            AdminCategoriesScreen(),
          ),
          _buildDrawerItem(
            context,
            Icons.people_rounded,
            'Người dùng',
            const AdminUsersScreen(),
          ),
          _buildDrawerItem(
            context,
            Icons.analytics_rounded,
            'Báo cáo',
            const AdminStatisticsScreen(),
          ),
          const Divider(color: AppColors.divider),
          _buildDrawerItem(context, Icons.settings_rounded, 'Cài đặt',
               const AdminSettingsScreen()),
          ListTile(
            leading: const Icon(
              Icons.logout_rounded,
              color: AppColors.textPrimary,
            ),
            title: const Text('Đăng xuất', style: AppTextStyles.body),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title, [
    Widget? screen,
  ]) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimary),
      title: Text(title, style: AppTextStyles.body),
      onTap: () {
        Navigator.pop(context);
        if (screen != null) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
        } else {
          debugPrint('Chưa gắn màn hình cho: $title');
        }
      },
    );
  }
}
