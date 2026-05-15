// lib/views/orders_screen.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../models/order_model.dart';
import '../../../widgets/common/category_chip.dart';
import '../../../widgets/navigation/app_bottom_nav.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  int _selectedFilter = 0;
  final List<String> _filters = [
    'Tất cả',
    'Đang giao',
    'Hoàn thành',
    'Đã huỷ',
  ];

  List<OrderModel> get _filteredOrders {
    if (_selectedFilter == 0) return OrderModel.sampleOrders;
    final statusMap = {
      1: OrderStatus.delivering,
      2: OrderStatus.completed,
      3: OrderStatus.cancelled,
    };
    return OrderModel.sampleOrders
        .where((o) => o.status == statusMap[_selectedFilter])
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 10),
              child: Text(
                'Đơn hàng của tôi',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filters.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, i) => CategoryChip(
                  label: _filters[i],
                  isActive: _selectedFilter == i,
                  onTap: () => setState(() => _selectedFilter = i),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _filteredOrders.isEmpty
                  ? _buildEmpty()
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 20),
                      itemCount: _filteredOrders.length,
                      itemBuilder: (context, i) =>
                          _buildOrderCard(_filteredOrders[i]),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    // Lấy ảnh món đầu tiên trong đơn để hiển thị đại diện
    final firstItem = order.items.isNotEmpty ? order.items.first : null;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.orderDetail,
        arguments: order,
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Ảnh món ăn đầu tiên thay cho emoji nhà hàng
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.pastel1,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: firstItem?.foodImageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.asset(
                            firstItem!.foodImageUrl!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(Icons.fastfood, color: AppColors.accent1),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Mã đơn hàng — khớp order_code trong SQL
                      Text(
                        'Đơn ${order.orderCode}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        order.itemsSummary,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textMuted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(order.status),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFF5EEE9)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Thời gian tạo đơn — khớp created_at trong SQL
                Text(
                  order.createdAt,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textMuted),
                ),
                // Tổng tiền — khớp total_amount trong SQL
                Text(
                  '${(order.totalAmount / 1000).toStringAsFixed(0)}.000đ',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: order.status == OrderStatus.cancelled
                        ? AppColors.textMuted
                        : AppColors.accent1,
                  ),
                ),
              ],
            ),

            // Nút đặt lại / đánh giá cho đơn đã hoàn thành
            // Khớp bảng reviews trong SQL
            if (order.status == OrderStatus.completed) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.home),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.pastel1,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Đặt lại',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accent1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.review,
                        arguments: order,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5EEE9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          '⭐ Đánh giá',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Nút theo dõi cho đơn đang xử lý
            if (order.status == OrderStatus.delivering ||
                order.status == OrderStatus.preparing) ...[
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => Navigator.pushNamed(
                    context, AppRoutes.tracking,
                    arguments: order),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.pastel2,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '🛵 Theo dõi đơn hàng',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.statusDeliveringText,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: status.textColor,
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🛍️', style: TextStyle(fontSize: 64)),
          SizedBox(height: 12),
          Text(
            'Chưa có đơn hàng nào',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Đặt món ngay để bắt đầu!',
            style: TextStyle(fontSize: 14, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}