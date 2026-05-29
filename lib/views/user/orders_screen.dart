// lib/views/user/orders_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../data/providers/order_provider.dart';
import '../../../data/providers/user_provider.dart';
import '../../../models/order_item_model.dart';
import '../../../models/order_model.dart';
import '../../../widgets/navigation/app_bottom_nav.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  int _selectedFilter = 0;
  bool _firstLoadTriggered = false;

  // Value (English, khớp DB CHECK) là nguồn duy nhất; label tiếng Việt
  // derive qua extension OrderStatusLabel ở order_model.dart.
  static const List<String?> _filterStatuses = [
    null,
    OrderStatus.shipping,
    OrderStatus.completed,
    OrderStatus.cancelled,
  ];

  String _labelFor(String? status) {
    if (status == null) return 'Tất cả';
    return status.label;
  }

  String? _statusFor(int filterIndex) => _filterStatuses[filterIndex];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_firstLoadTriggered) return;
    _firstLoadTriggered = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadOrders());
  }

  Future<void> _loadOrders() async {
    if (!mounted) return;
    final userProvider = context.read<UserProvider>();
    final orderProvider = context.read<OrderProvider>();

    final userId =
        userProvider.currentUserId ?? userProvider.currentUser?.userId;
    final status = _statusFor(_selectedFilter);

    if (userId != null) {
      await orderProvider.fetchOrdersByUserIdAndStatus(userId, status);
    } else {
      await orderProvider.fetchOrders();
    }
  }

  void _onFilterTap(int index) {
    if (_selectedFilter == index) return;
    setState(() => _selectedFilter = index);
    _loadOrders();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(date.day)}/${two(date.month)}/${date.year}  ${two(date.hour)}:${two(date.minute)}';
  }

  String _formatMoney(double amount) {
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}.000đ';
    }
    return '${amount.toStringAsFixed(0)}đ';
  }

  String _firstLetter(String s) {
    final t = s.trim();
    if (t.isEmpty) return '?';
    return t.characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            _buildFilterBar(),
            const SizedBox(height: 6),
            Expanded(
              child: Consumer<OrderProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading && provider.orders.isEmpty) {
                    return _buildLoading();
                  }
                  if (provider.error != null && provider.orders.isEmpty) {
                    return _buildEmpty();
                  }
                  final list = provider.orders;
                  if (list.isEmpty) return _buildEmpty();

                  return RefreshIndicator(
                    onRefresh: _loadOrders,
                    color: AppColors.accent1,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      itemCount: list.length,
                      itemBuilder: (context, i) => _buildOrderCard(list[i]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }

  // =========================================================
  // HEADER với title + count summary
  // =========================================================
  Widget _buildHeader() {
    return Consumer<OrderProvider>(
      builder: (context, provider, _) {
        final total = provider.orders.length;
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Đơn hàng của tôi',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Quản lý & theo dõi đơn của bạn',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              // Pill counter
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.pastel1,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.receipt_long_rounded,
                      size: 16,
                      color: AppColors.accent1,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$total',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.accent1,
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
  // FILTER PILL CHIPS — selected: gradient fill, others: outlined
  // =========================================================
  Widget _buildFilterBar() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        itemCount: _filterStatuses.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final isActive = _selectedFilter == i;
          final label = _labelFor(_filterStatuses[i]);

          return GestureDetector(
            onTap: () => _onFilterTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: isActive
                    ? const LinearGradient(
                        colors: [AppColors.accent1, Color(0xFFFFAB7E)],
                      )
                    : null,
                color: isActive ? null : AppColors.card,
                borderRadius: BorderRadius.circular(14),
                border: isActive
                    ? null
                    : Border.all(color: AppColors.divider, width: 1),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppColors.accent1.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isActive ? Colors.white : AppColors.textMuted,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // =========================================================
  // ORDER CARD — luxury redesign with thumb stack + status hero
  // =========================================================
  Widget _buildOrderCard(OrderModel order) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.orderDetail,
        arguments: order,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top strip — order code + status badge
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 14, 10),
              decoration: BoxDecoration(
                color: order.status.bgColor.withOpacity(0.4),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      size: 18,
                      color: AppColors.accent1,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Đơn ${order.orderCode}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 1),
                        Text(
                          _formatDate(order.createdAt),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: order.status.bgColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: order.status.textColor.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      order.status.label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: order.status.textColor,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Image thumbnails row
            if (order.items.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                child: _buildThumbStack(order.items),
              ),

            // Items summary
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Text(
                order.itemsSummary.isEmpty
                    ? 'Không có món nào'
                    : order.itemsSummary,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(height: 1, color: Color(0xFFF5EEE9)),
            ),

            // Footer — total + actions
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text(
                        'Tổng cộng',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatMoney(order.totalAmount),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: (order.status == OrderStatus.cancelled)
                              ? AppColors.textMuted
                              : AppColors.accent1,
                        ),
                      ),
                    ],
                  ),

                  if (order.status == OrderStatus.completed) ...[
                    const SizedBox(height: 12),
                    _buildCompletedActions(order),
                  ],

                  if (order.status == OrderStatus.shipping ||
                      order.status == OrderStatus.preparing) ...[
                    const SizedBox(height: 12),
                    _buildTrackingButton(order),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedActions(OrderModel order) {
    return Row(
      children: [
        Expanded(
          child: _outlineButton(
            icon: Icons.refresh_rounded,
            label: 'Đặt lại',
            color: AppColors.accent1,
            onTap: () => Navigator.pushNamed(context, AppRoutes.home),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _filledButton(
            icon: Icons.star_rounded,
            label: 'Đánh giá',
            gradient: const [AppColors.accent4, Color(0xFFFFC95C)],
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.review,
              arguments: order,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrackingButton(OrderModel order) {
    return _filledButton(
      icon: Icons.delivery_dining_rounded,
      label: 'Theo dõi đơn hàng',
      gradient: const [AppColors.accent2, Color(0xFF7AC2F0)],
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.tracking,
        arguments: order,
      ),
    );
  }

  Widget _outlineButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38,
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filledButton({
    required IconData icon,
    required String label,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withOpacity(0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // THUMB STACK — chồng 3 ảnh đầu + badge "+N" nếu nhiều hơn
  // =========================================================
  Widget _buildThumbStack(List<OrderItemModel> items) {
    final visible = items.take(3).toList();
    final extra = items.length - visible.length;

    return SizedBox(
      height: 56,
      child: Row(
        children: [
          // Stacked thumbnails
          SizedBox(
            width: visible.length * 38.0 + 18,
            height: 56,
            child: Stack(
              children: List.generate(visible.length, (i) {
                return Positioned(
                  left: i * 38.0,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _buildThumb(visible[i]),
                    ),
                  ),
                );
              }),
            ),
          ),
          if (extra > 0) ...[
            const SizedBox(width: 4),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.pastel1,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                '+$extra',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.accent1,
                ),
              ),
            ),
          ],
          const Spacer(),
          // count items chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.pastel5,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.fastfood_rounded,
                  size: 12,
                  color: AppColors.accent5,
                ),
                const SizedBox(width: 4),
                Text(
                  '${items.length} món',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Thumbnail của 1 item — ưu tiên URL → asset → fallback chữ cái đầu
  Widget _buildThumb(OrderItemModel item) {
    final url = item.foodImageUrl;
    final letter = _firstLetter(item.foodName);

    if (url == null || url.isEmpty) {
      return _initialBox(letter);
    }
    final isNet = url.startsWith('http');
    return isNet
        ? Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _initialBox(letter),
          )
        : Image.asset(
            url,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _initialBox(letter),
          );
  }

  Widget _initialBox(String letter) {
    return Container(
      color: AppColors.pastel1,
      alignment: Alignment.center,
      child: Text(
        letter,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: AppColors.accent1,
        ),
      ),
    );
  }

  // =========================================================
  // LOADING — 3 skeleton cards
  // =========================================================
  Widget _buildLoading() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      itemCount: 3,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 14),
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  // =========================================================
  // EMPTY STATE
  // =========================================================
  Widget _buildEmpty() {
    return RefreshIndicator(
      onRefresh: _loadOrders,
      color: AppColors.accent1,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 80),
          Center(
            child: Column(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.pastel1,
                        AppColors.pastel5.withOpacity(0.7),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '🛍️',
                    style: TextStyle(fontSize: 56),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Chưa có đơn hàng nào',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Đặt món ngay để bắt đầu hành trình ẩm thực của bạn!',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.home),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.accent1, Color(0xFFFFAB7E)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent1.withOpacity(0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.restaurant_menu_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Khám phá menu',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
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
    );
  }
}
