// lib/views/tracking_screen.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../models/order_model.dart';
import '../../../widgets/common/back_button_widget.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(date.day)}/${two(date.month)}/${date.year} ${two(date.hour)}:${two(date.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    // Nhận OrderModel từ arguments — khớp với cách truyền từ orders_screen
    final order = ModalRoute.of(context)?.settings.arguments as OrderModel?
        ?? OrderModel.sampleOrders.first;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Row(
                children: [
                  BackButtonWidget(
                    onTap: () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.orders,
                      (r) => false,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Theo dõi đơn hàng',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      // Hiển thị order_code từ SQL
                      Text(
                        '${order.orderCode}  •  Dự kiến 25 phút',
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildMapArea(),
                    const SizedBox(height: 36),
                    _buildStepList(order),
                    const SizedBox(height: 16),
                    _buildOrderSummaryCard(order),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapArea() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 180,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.pastel3, AppColors.pastel2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          alignment: Alignment.center,
          child: const Text('🗺️', style: TextStyle(fontSize: 52)),
        ),
        Positioned(
          bottom: -22,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.pastel2,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text('🛵',
                        style: TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nguyễn Văn Tài',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '⭐ 4.9  •  Tài xế giao hàng',
                        style: TextStyle(
                            fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.pastel3,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      '📞 Gọi',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Các bước khớp đúng với status trong SQL:
  // confirmed → preparing → shipping → completed
  Widget _buildStepList(OrderModel order) {
    final bool isConfirmed = true; // đơn đã tạo thì luôn confirmed
    final bool isPreparing = order.status == OrderStatus.preparing ||
        order.status == OrderStatus.shipping ||
        order.status == OrderStatus.completed;
    final bool isDelivering = order.status == OrderStatus.shipping ||
        order.status == OrderStatus.completed;
    final bool isCompleted = order.status == OrderStatus.completed;

    final steps = [
      {
        'icon': '✅',
        'title': 'Đơn hàng đã được xác nhận',
        'time': '${_formatDate(order.createdAt)}  •  Cửa hàng đã nhận đơn',
        'done': isConfirmed,
        'active': false,
      },
      {
        'icon': '🍳',
        'title': 'Đang chuẩn bị món ăn',
        'time': 'Đầu bếp đang nấu',
        'done': isPreparing,
        'active': order.status == OrderStatus.preparing,
      },
      {
        'icon': '🛵',
        'title': 'Đang giao hàng',
        'time': 'Tài xế đang trên đường',
        'done': isDelivering,
        'active': order.status == OrderStatus.shipping,
      },
      {
        'icon': '📦',
        'title': 'Giao hàng thành công',
        'time': 'Dự kiến ~25 phút',
        'done': isCompleted,
        'active': false,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: List.generate(steps.length, (i) {
          final step = steps[i];
          final bool done = step['done'] as bool? ?? false;
          final bool active = step['active'] as bool? ?? false;
          final bool isLast = i == steps.length - 1;
          final Color dotColor = done
              ? AppColors.accent3
              : (active
                  ? AppColors.accent4
                  : const Color(0xFFE0D5CF));

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    margin: const EdgeInsets.only(top: 3),
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 44,
                      color: done
                          ? AppColors.accent3.withOpacity(0.3)
                          : const Color(0xFFE0D5CF),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${step['icon']}  ${step['title']}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: done || active
                              ? AppColors.textPrimary
                              : AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        step['time'] as String,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // Hiển thị dữ liệu thực từ OrderModel — khớp order_items, total_amount SQL
  Widget _buildOrderSummaryCard(OrderModel order) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.pastel2,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📋 Chi tiết đơn hàng',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.accent2,
            ),
          ),
          const SizedBox(height: 8),
          // Địa chỉ giao hàng — khớp delivery_address SQL
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 14, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  order.deliveryAddress,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Danh sách món — khớp order_items SQL
          Text(
            order.itemsSummary,
            style: const TextStyle(
                fontSize: 13, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          const Divider(color: Color(0x33185FA5), height: 1),
          const SizedBox(height: 8),
          // Tổng tiền — khớp total_amount SQL
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng cộng',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent2,
                ),
              ),
              Text(
                '${(order.totalAmount / 1000).toStringAsFixed(0)}.000đ',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.accent2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}