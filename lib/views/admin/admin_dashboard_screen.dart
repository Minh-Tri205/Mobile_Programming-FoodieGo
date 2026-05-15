import 'package:doancuoiki/views/admin/admin_orders_screen.dart';
import 'package:doancuoiki/views/admin/admin_products_screen.dart';
import 'package:doancuoiki/views/admin/admin_statistics_screen.dart';
import 'package:doancuoiki/views/admin/admin_users_screen.dart';
import 'package:doancuoiki/widgets/admin_widgets/admin_drawer.dart';
import 'package:doancuoiki/widgets/admin_widgets/dashboard_card.dart';
import 'package:doancuoiki/widgets/admin_widgets/revenue_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AdminDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text('Bảng điều khiển', style: AppTextStyles.heading2),
        actions: [
          Padding(padding: .all(20), child: Icon(Icons.settings_rounded)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Xin chào Admin!", style: AppTextStyles.heading1),
            const SizedBox(height: 8),
            const Text(
              'Theo dõi hoạt động kinh doanh và hiệu suất cửa hàng.',
              style: AppTextStyles.bodyMuted,
            ),
            const SizedBox(height: 24),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.15,
              children: [
                DashboardCard(
                  title: 'Doanh thu',
                  value: '48.5M',
                  icon: Icons.attach_money_rounded,
                  backgroundColor: AppColors.pastel1,
                  iconColor: AppColors.accent1,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminStatisticsScreen(),
                      ),
                    );
                  },
                ),
                DashboardCard(
                  title: 'Đơn hàng',
                  value: '1,245',
                  icon: Icons.shopping_bag_rounded,
                  backgroundColor: AppColors.pastel2,
                  iconColor: AppColors.accent2,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminOrdersScreen(),
                      ),
                    );
                  },
                ),
                DashboardCard(
                  title: 'Khách hàng',
                  value: '892',
                  icon: Icons.people_alt_rounded,
                  backgroundColor: AppColors.pastel3,
                  iconColor: AppColors.accent3,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminUsersScreen(),
                      ),
                    );
                  },
                ),
                DashboardCard(
                  title: 'Sản phẩm',
                  value: '156',
                  icon: Icons.inventory_2_rounded,
                  backgroundColor: AppColors.pastel5,
                  iconColor: AppColors.accent5,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminProductsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            const RevenueChart(),
          ],
        ),
      ),
    );
  }
}
