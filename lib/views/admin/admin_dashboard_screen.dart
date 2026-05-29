// lib/views/admin/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../data/providers/category_provider.dart';
import '../../data/providers/food_provider.dart';
import '../../data/providers/order_provider.dart';
import '../../data/providers/user_provider.dart';
import '../../models/order_model.dart';
import '../../widgets/admin_widgets/admin_drawer.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAll());
  }

  Future<void> _loadAll() async {
    if (!mounted) return;
    final orderProv = context.read<OrderProvider>();
    final foodProv = context.read<FoodProvider>();
    final catProv = context.read<CategoryProvider>();
    final userProv = context.read<UserProvider>();

    await Future.wait([
      if (orderProv.orders.isEmpty) orderProv.fetchOrders(),
      if (foodProv.foods.isEmpty) foodProv.fetchFoods(),
      if (catProv.categories.isEmpty) catProv.fetchCategories(),
      if (userProv.users.isEmpty) userProv.fetchUsers(),
    ]);
  }

  // =========================================================
  // HELPERS
  // =========================================================
  bool _isToday(DateTime? d) {
    if (d == null) return false;
    final n = DateTime.now();
    return d.year == n.year && d.month == n.month && d.day == n.day;
  }

  String _money(double a) {
    if (a >= 1000000000) return '${(a / 1000000000).toStringAsFixed(1)}B';
    if (a >= 1000000) return '${(a / 1000000).toStringAsFixed(1)}M';
    if (a >= 1000) return '${(a / 1000).toStringAsFixed(0)}K';
    return a.toStringAsFixed(0);
  }

  String _moneyFull(double a) {
    final s = a.toStringAsFixed(0);
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return '${buf.toString()}đ';
  }

  String _formatTime(DateTime? d) {
    if (d == null) return '';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.hour)}:${two(d.minute)}';
  }

  // =========================================================
  // BUILD
  // =========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AdminDrawer(),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.accent1,
          onRefresh: _loadAll,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              _buildHeader(),
              const SizedBox(height: 6),
              _buildTodayCard(),
              const SizedBox(height: 16),
              _buildSectionTitle('Tổng quan'),
              _buildOverviewGrid(),
              const SizedBox(height: 18),
              _buildSectionTitle(
                'Doanh thu 7 ngày qua',
                trailing: _seeAll(AppRoutes.adminStatistics),
              ),
              _buildMiniChart(),
              const SizedBox(height: 18),
              _buildSectionTitle('Hành động nhanh'),
              _buildQuickActions(),
              const SizedBox(height: 18),
              _buildSectionTitle(
                'Đơn hàng gần đây',
                trailing: _seeAll(AppRoutes.adminOrders),
              ),
              _buildRecentOrders(),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // HEADER — menu + greeting + bell
  // =========================================================
  Widget _buildHeader() {
    return Consumer<UserProvider>(
      builder: (context, prov, _) {
        final name = prov.currentUser?.fullName ?? 'Admin';
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Row(
            children: [
              Builder(
                builder: (ctx) => GestureDetector(
                  onTap: () => Scaffold.of(ctx).openDrawer(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.menu_rounded,
                      size: 20,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chào, $name 👋',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Bảng điều khiển quản trị',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.notifications_outlined,
                      size: 20,
                      color: AppColors.accent1,
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.accent1,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.card, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // =========================================================
  // TODAY CARD — doanh thu hôm nay (gradient lớn)
  // =========================================================
  Widget _buildTodayCard() {
    return Consumer<OrderProvider>(
      builder: (context, prov, _) {
        final today = prov.orders.where((o) => _isToday(o.createdAt));
        final revenueToday = today
            .where((o) => o.status != OrderStatus.cancelled)
            .fold<double>(0, (s, o) => s + o.totalAmount);
        final ordersToday = today.length;
        final completedToday =
            today.where((o) => o.status == OrderStatus.completed).length;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.accent1, Color(0xFFFFAB7E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent1.withOpacity(0.4),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.22),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.calendar_today_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Doanh thu hôm nay',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _moneyFull(revenueToday),
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _todayBadge(
                    icon: Icons.receipt_long_rounded,
                    label: '$ordersToday đơn',
                  ),
                  const SizedBox(width: 8),
                  _todayBadge(
                    icon: Icons.check_circle_rounded,
                    label: '$completedToday hoàn thành',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _todayBadge({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.22),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // OVERVIEW GRID — 4 cards
  // =========================================================
  Widget _buildOverviewGrid() {
    return Consumer4<OrderProvider, FoodProvider, UserProvider,
        CategoryProvider>(
      builder: (context, ordersP, foodsP, usersP, catP, _) {
        final totalRevenue = ordersP.orders
            .where((o) => o.status != OrderStatus.cancelled)
            .fold<double>(0, (s, o) => s + o.totalAmount);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.3,
            children: [
              _statCard(
                icon: Icons.payments_rounded,
                label: 'Tổng doanh thu',
                value: _moneyFull(totalRevenue),
                bg: AppColors.pastel1,
                accent: AppColors.accent1,
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.adminStatistics),
              ),
              _statCard(
                icon: Icons.shopping_bag_rounded,
                label: 'Tổng đơn hàng',
                value: '${ordersP.orders.length}',
                bg: AppColors.pastel2,
                accent: AppColors.accent2,
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.adminOrders),
              ),
              _statCard(
                icon: Icons.people_alt_rounded,
                label: 'Khách hàng',
                value: '${usersP.users.length}',
                bg: AppColors.pastel3,
                accent: AppColors.accent3,
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.adminUsers),
              ),
              _statCard(
                icon: Icons.fastfood_rounded,
                label: 'Món ăn',
                value: '${foodsP.foods.length}',
                bg: AppColors.pastel5,
                accent: AppColors.accent5,
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.adminProducts),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    required Color bg,
    required Color accent,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: accent, size: 20),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: AppColors.textMuted.withOpacity(0.6),
                ),
              ],
            ),
            const SizedBox(height: 10),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // MINI CHART — 7-day revenue bars
  // =========================================================
  Widget _buildMiniChart() {
    return Consumer<OrderProvider>(
      builder: (context, prov, _) {
        final now = DateTime.now();
        final start = DateTime(now.year, now.month, now.day)
            .subtract(const Duration(days: 6));
        // 7 buckets
        final buckets = List<double>.generate(7, (_) => 0);
        for (final o in prov.orders) {
          final d = o.createdAt;
          if (d == null) continue;
          if (d.isBefore(start)) continue;
          if (o.status == OrderStatus.cancelled) continue;
          final diff = DateTime(d.year, d.month, d.day).difference(start).inDays;
          if (diff >= 0 && diff < 7) {
            buckets[diff] += o.totalAmount;
          }
        }
        final maxV = buckets.fold<double>(0, (m, v) => v > m ? v : m);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              SizedBox(
                height: 110,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(7, (i) {
                    final ratio = maxV > 0 ? buckets[i] / maxV : 0.0;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (buckets[i] > 0)
                              Text(
                                _money(buckets[i]),
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.accent1,
                                ),
                              ),
                            const SizedBox(height: 2),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 320),
                              height: 6 + ratio * 80,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: ratio > 0
                                      ? [
                                          AppColors.accent1,
                                          const Color(0xFFFFAB7E),
                                        ]
                                      : [AppColors.divider, AppColors.divider],
                                ),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: List.generate(7, (i) {
                  final d = start.add(Duration(days: i));
                  return Expanded(
                    child: Text(
                      '${d.day}/${d.month}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 9,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  // =========================================================
  // QUICK ACTIONS — 4 navigation tiles
  // =========================================================
  Widget _buildQuickActions() {
    final actions = [
      _Action(
        icon: Icons.add_circle_rounded,
        label: 'Thêm món',
        bg: AppColors.pastel1,
        accent: AppColors.accent1,
        route: AppRoutes.adminAddProduct,
      ),
      _Action(
        icon: Icons.category_rounded,
        label: 'Danh mục',
        bg: AppColors.pastel2,
        accent: AppColors.accent2,
        route: AppRoutes.adminCategories,
      ),
      _Action(
        icon: Icons.people_rounded,
        label: 'Người dùng',
        bg: AppColors.pastel3,
        accent: AppColors.accent3,
        route: AppRoutes.adminUsers,
      ),
      _Action(
        icon: Icons.bar_chart_rounded,
        label: 'Báo cáo',
        bg: AppColors.pastel5,
        accent: AppColors.accent5,
        route: AppRoutes.adminStatistics,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: actions
            .map(
              (a) => Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, a.route),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: a.bg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(a.icon, color: a.accent, size: 20),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          a.label,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  // =========================================================
  // RECENT ORDERS — 5 mới nhất
  // =========================================================
  Widget _buildRecentOrders() {
    return Consumer<OrderProvider>(
      builder: (context, prov, _) {
        final sorted = [...prov.orders]
          ..sort((a, b) {
            final ad = a.createdAt ?? DateTime(0);
            final bd = b.createdAt ?? DateTime(0);
            return bd.compareTo(ad);
          });
        final recent = sorted.take(5).toList();

        if (recent.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Chưa có đơn hàng nào',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
            ),
          );
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: List.generate(recent.length, (i) {
              final order = recent[i];
              final isLast = i == recent.length - 1;
              return Column(
                children: [
                  _recentOrderRow(order),
                  if (!isLast)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Divider(height: 1, color: Color(0xFFF5EEE9)),
                    ),
                ],
              );
            }),
          ),
        );
      },
    );
  }

  Widget _recentOrderRow(OrderModel order) {
    return InkWell(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.orderDetail,
        arguments: order,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: order.status.bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(
                _statusIcon(order.status),
                color: order.status.textColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.orderCode,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          order.recipientName,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          color: AppColors.textMuted,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatTime(order.createdAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${_money(order.totalAmount)}đ',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.accent1,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: order.status.bgColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    order.status.label,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: order.status.textColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.hourglass_top_rounded;
      case OrderStatus.confirmed:
        return Icons.task_alt_rounded;
      case OrderStatus.preparing:
        return Icons.restaurant_rounded;
      case OrderStatus.shipping:
        return Icons.delivery_dining_rounded;
      case OrderStatus.completed:
        return Icons.check_circle_rounded;
      case OrderStatus.cancelled:
        return Icons.cancel_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  // =========================================================
  // SECTION TITLE + SEE ALL
  // =========================================================
  Widget _buildSectionTitle(String title, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.accent1,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _seeAll(String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: const Row(
        children: [
          Text(
            'Xem tất cả',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.accent1,
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            size: 16,
            color: AppColors.accent1,
          ),
        ],
      ),
    );
  }
}

class _Action {
  final IconData icon;
  final String label;
  final Color bg;
  final Color accent;
  final String route;
  const _Action({
    required this.icon,
    required this.label,
    required this.bg,
    required this.accent,
    required this.route,
  });
}
